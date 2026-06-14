class GenerateQuestionsJob < ApplicationJob
  queue_as :default

  def perform(summary_id)
    summary = Summary.find_by(id: summary_id)
    return unless summary

    GenerateQuestionsService.call(summary)
  end
end
