class GenerateQuestionsService
  def self.call(summary)
    new(summary).call
  end

  def initialize(summary)
    @summary = summary
  end

  def call
    @summary.update!(status: :processing)

    begin
      prompt = File.read(Rails.root.join("lib", "prompts", "generate_questions.txt"))
      
      questions_data = GeminiClient.generate_questions(
        prompt: prompt,
        content: @summary.content,
        count: @summary.questions_requested
      )

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
end
