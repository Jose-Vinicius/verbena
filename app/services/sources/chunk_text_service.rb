module Sources
  class ChunkTextService
    MAX_CHARS = 2500
    OVERLAP_CHARS = 200

    def self.call(study_source, segments)
      new(study_source, segments).call
    end

    def initialize(study_source, segments)
      @study_source = study_source
      @segments = segments
    end

    def call
      chunks_attributes = []
      position = 0
      now = Time.current

      @segments.each do |segment|
        split_into_chunks(segment[:text]).each do |chunk_text|
          chunks_attributes << {
            study_source_id: @study_source.id,
            position: position,
            content: chunk_text,
            char_count: chunk_text.length,
            used_count: 0,
            metadata: segment[:metadata] || {},
            created_at: now,
            updated_at: now
          }
          position += 1
        end
      end

      ActiveRecord::Base.transaction do
        @study_source.source_chunks.kept.update_all(deleted_at: now, updated_at: now)
        SourceChunk.insert_all!(chunks_attributes) if chunks_attributes.any?
      end

      {
        pages_count: @segments.size,
        chunks_count: chunks_attributes.size
      }
    end

    private

    def split_into_chunks(text)
      return [ text ] if text.length <= MAX_CHARS

      chunks = []
      start_idx = 0

      while start_idx < text.length
        end_idx = [ start_idx + MAX_CHARS, text.length ].min

        if end_idx < text.length
          break_idx = find_natural_break(text, start_idx, end_idx)
          end_idx = break_idx if break_idx && break_idx > start_idx + (MAX_CHARS / 2)
        end

        chunk = text[start_idx...end_idx].strip
        chunks << chunk if chunk.present?

        break if end_idx >= text.length

        start_idx = [ end_idx - OVERLAP_CHARS, start_idx + 1 ].max
      end

      chunks
    end

    def find_natural_break(text, start_idx, end_idx)
      window = text[start_idx...end_idx]
      last_double_newline = window.rindex("\n\n")
      return start_idx + last_double_newline if last_double_newline

      last_newline = window.rindex("\n")
      return start_idx + last_newline if last_newline

      last_sentence = window.rindex(". ")
      return start_idx + last_sentence + 1 if last_sentence

      last_space = window.rindex(" ")
      last_space ? start_idx + last_space : nil
    end
  end
end
