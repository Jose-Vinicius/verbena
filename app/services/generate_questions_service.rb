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
      # Simulate processing delay
      sleep 3

      @summary.update!(status: :done)
    rescue StandardError => e
      Rails.logger.error "Failed to generate questions: #{e.message}"
      @summary.update!(status: :error)
    end
  end
end
