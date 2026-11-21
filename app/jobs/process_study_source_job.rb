class ProcessStudySourceJob < ApplicationJob
  queue_as :default

  def perform(study_source_id)
    study_source = StudySource.kept.find_by(id: study_source_id)
    return unless study_source

    study_source.update!(status: :processing, error_message: nil)

    segments = Sources::ExtractTextService.call(study_source)
    stats = Sources::ChunkTextService.call(study_source, segments)

    study_source.update!(
      status: :ready,
      pages_count: stats[:pages_count],
      chunks_count: stats[:chunks_count],
      error_message: nil
    )
  rescue StandardError => e
    Rails.logger.error "Failed to process StudySource #{study_source_id}: #{e.message}"
    study_source&.update(status: :error, error_message: e.message.truncate(500))
  end
end
