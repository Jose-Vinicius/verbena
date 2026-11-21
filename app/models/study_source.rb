class StudySource < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  belongs_to :subject
  has_many :source_chunks, dependent: :destroy
  has_one_attached :file

  enum :source_type, { pdf: 0, pptx: 1, docx: 2, text: 3 }, default: :text
  enum :status, { pending: 0, processing: 1, ready: 2, error: 3 }, default: :pending

  validates :title, presence: true
  validate :subject_must_be_active, on: :create

  scope :selected_for_generation, -> { active.ready.where(selected: true) }

  after_update_commit :broadcast_status_update

  def soft_delete!(timestamp = Time.current)
    transaction do
      update!(deleted_at: timestamp)
      source_chunks.kept.update_all(deleted_at: timestamp, updated_at: timestamp)
    end
  end

  def self.detect_source_type(filename)
    ext = File.extname(filename.to_s).downcase
    case ext
    when ".pdf" then :pdf
    when ".pptx" then :pptx
    when ".docx" then :docx
    else :text
    end
  end

  private

  def subject_must_be_active
    errors.add(:subject, "não encontrada ou inativa") if subject&.deleted?
  end

  def broadcast_status_update
    stream = [ user, "subject_#{subject_id}_sources" ]

    broadcast_replace_to(
      stream,
      target: "study_source_#{id}",
      partial: "study_sources/study_source",
      locals: { study_source: self }
    )

    broadcast_replace_to(
      stream,
      target: "generator_panel",
      partial: "study_sources/generator_panel",
      locals: {
        subject: subject,
        study_sources: subject.study_sources.active.order(created_at: :desc),
        summary: user.summaries.new(subject: subject),
        user: user
      }
    )
  end
end
