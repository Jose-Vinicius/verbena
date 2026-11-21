class Subject < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  has_many :summaries, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_many :group_quizzes, dependent: :destroy
  has_many :study_sources, dependent: :destroy

  validates :name, presence: true
  validates :color, presence: true

  before_validation :set_defaults, on: :create

  # Inativa a matéria junto com suas questões, resumos e fontes vinculadas em uma única transação.
  def soft_delete!(timestamp = Time.current)
    transaction do
      update!(deleted_at: timestamp)
      questions.active.update_all(deleted_at: timestamp, updated_at: timestamp)
      summaries.active.update_all(deleted_at: timestamp, updated_at: timestamp)
      source_ids = study_sources.active.pluck(:id)
      if source_ids.any?
        SourceChunk.kept.where(study_source_id: source_ids).update_all(deleted_at: timestamp, updated_at: timestamp)
        study_sources.where(id: source_ids).update_all(deleted_at: timestamp, updated_at: timestamp)
      end
    end
  end

  private

  def set_defaults
    self.color ||= "#a78bfa"
    self.icon = "schema" if self.icon.blank?
  end
end
