module Sources
  class SelectChunksService
    DEFAULT_CHAR_BUDGET = 28_000

    def self.call(study_source_ids:, focus_query: nil, target_char_budget: DEFAULT_CHAR_BUDGET, exclude_chunk_ids: [])
      new(
        study_source_ids: study_source_ids,
        focus_query: focus_query,
        target_char_budget: target_char_budget,
        exclude_chunk_ids: exclude_chunk_ids
      ).call
    end

    def initialize(study_source_ids:, focus_query: nil, target_char_budget: DEFAULT_CHAR_BUDGET, exclude_chunk_ids: [])
      @study_source_ids = Array(study_source_ids).map(&:to_i).uniq
      @focus_query = focus_query.to_s.strip.presence
      @target_char_budget = target_char_budget
      @exclude_chunk_ids = Array(exclude_chunk_ids).map(&:to_i)
    end

    def call
      return [] if @study_source_ids.empty?

      selected = if @focus_query.present?
        select_by_focus_query
      else
        select_stratified
      end

      # If batch excluded all chunks, retry without exclusions so generation still succeeds
      if selected.empty? && @exclude_chunk_ids.any?
        @exclude_chunk_ids = []
        selected = @focus_query.present? ? select_by_focus_query : select_stratified
      end

      if selected.any?
        SourceChunk.where(id: selected.map(&:id)).update_all("used_count = used_count + 1")
      end

      selected.sort_by { |chunk| [ chunk.study_source_id, chunk.position ] }
    end

    private

    def base_scope
      scope = SourceChunk.kept
                         .includes(:study_source)
                         .joins(:study_source)
                         .where(study_sources: { id: @study_source_ids, deleted_at: nil, status: StudySource.statuses[:ready] })

      scope = scope.where.not(id: @exclude_chunk_ids) if @exclude_chunk_ids.any?
      scope
    end

    def select_by_focus_query
      ranked = base_scope.search_full_text(@focus_query).limit(20).to_a
      picked = collect_within_budget(ranked)

      if picked.size < 2
        picked_ids = picked.map(&:id)
        remaining_budget = @target_char_budget - picked.sum(&:char_count)
        if remaining_budget > 0
          fallback = select_stratified(extra_exclude_ids: picked_ids, budget: remaining_budget)
          picked.concat(fallback)
        end
      end

      picked
    end

    def select_stratified(extra_exclude_ids: [], budget: @target_char_budget)
      scope = base_scope
      scope = scope.where.not(id: extra_exclude_ids) if extra_exclude_ids.any?

      grouped = scope.order(:used_count, :position).to_a.group_by(&:study_source_id)
      return [] if grouped.empty?

      queues = grouped.values
      picked = []
      used_chars = 0

      loop do
        added_in_round = false

        queues.each do |queue|
          next if queue.empty?

          candidate = queue.shift
          if picked.any? && (used_chars + candidate.char_count > budget)
            next
          end

          picked << candidate
          used_chars += candidate.char_count
          added_in_round = true

          return picked if used_chars >= budget
        end

        break unless added_in_round
      end

      picked
    end

    def collect_within_budget(chunks)
      picked = []
      used_chars = 0

      chunks.each do |chunk|
        break if picked.any? && (used_chars + chunk.char_count > @target_char_budget)

        picked << chunk
        used_chars += chunk.char_count
      end

      picked
    end
  end
end
