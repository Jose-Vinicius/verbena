class Summary < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  belongs_to :subject

  enum :status, { pending: 0, processing: 1, done: 2, error: 3 }, default: :pending

  validates :content, presence: true, length: { maximum: 100_000 }, unless: :from_study_sources?
  validates :questions_requested, presence: true, inclusion: { in: [ 10, 20, 30 ] }
  validate :subject_must_be_active, on: :create
  validate :must_have_selected_sources, if: :from_study_sources?, on: :create

  after_update_commit -> { broadcast_replace_to [ user, "summaries" ], target: "summary_#{id}", partial: "summaries/status", locals: { summary: self } }

  def from_study_sources?
    study_source_ids.present?
  end

  def study_sources
    return StudySource.none unless from_study_sources?

    StudySource.kept.where(id: study_source_ids)
  end

  private

  def subject_must_be_active
    errors.add(:subject, "não encontrada ou inativa") if subject&.deleted?
  end

  def must_have_selected_sources
    return if study_sources.ready.exists?

    errors.add(:base, "Selecione pelo menos uma fonte pronta para gerar questões.")
  end
end
