class GenerateQuestionsService
  BATCH_SIZE = 10

  def self.call(summary)
    new(summary).call
  end

  def initialize(summary)
    @summary = summary
  end

  def call
    @summary.update!(status: :processing)

    begin
      prompt = build_prompt
      preferred_model = @summary.user&.effective_gemini_model || GeminiClient::DEFAULT_MODEL

      questions_data = if @summary.from_study_sources?
        generate_from_study_sources(prompt: prompt, preferred_model: preferred_model)
      else
        GeminiClient.generate_questions(
          prompt: prompt,
          content: @summary.content,
          count: @summary.questions_requested,
          default_model: preferred_model
        )
      end

      ActiveRecord::Base.transaction do
        questions_data.each do |q_data|
          Question.create!(
            summary: @summary,
            subject: @summary.subject,
            statement: q_data["statement"],
            options: q_data["options"],
            correct_index: q_data["correct_index"],
            explanation: q_data["explanation"]
          )
        end
        @summary.update!(status: :done)
      end
    rescue StandardError => e
      Rails.logger.error "Failed to generate questions: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @summary.update!(status: :error)
    end
  end

  private

  def build_prompt
    base_prompt = @summary.user&.effective_prompt || GeminiClient.default_prompt
    return base_prompt if @summary.focus_query.blank?

    "#{base_prompt}\n\nDIRECIONAMENTO ESPECÍFICO DO USUÁRIO:\nPriorize e foque as questões no seguinte tema/tópico: #{@summary.focus_query}"
  end

  def generate_from_study_sources(prompt:, preferred_model:)
    remaining = @summary.questions_requested
    used_chunk_ids = []
    all_questions = []

    while remaining > 0
      batch_count = [ remaining, BATCH_SIZE ].min
      chunks = Sources::SelectChunksService.call(
        study_source_ids: @summary.study_source_ids,
        focus_query: @summary.focus_query,
        exclude_chunk_ids: used_chunk_ids
      )
      raise "Nenhum conteúdo processado encontrado nas fontes selecionadas." if chunks.empty?

      used_chunk_ids.concat(chunks.map(&:id))
      batch_content = chunks.map do |chunk|
        "--- [Fonte: #{chunk.source_label}] ---\n#{chunk.content}"
      end.join("\n\n")

      batch_questions = GeminiClient.generate_questions(
        prompt: prompt,
        content: batch_content,
        count: batch_count,
        default_model: preferred_model
      )

      all_questions.concat(batch_questions)
      remaining -= batch_count
    end

    all_questions
  end
end
