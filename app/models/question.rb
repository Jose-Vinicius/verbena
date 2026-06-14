class Question < ApplicationRecord
  belongs_to :summary
  belongs_to :subject
  has_many :exam_questions, dependent: :destroy
  has_many :exams, through: :exam_questions

  validates :statement, presence: true
  validates :correct_index, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }
  validate :options_format

  scope :by_subject, ->(subject_id) { where(subject_id: subject_id) }

  private

  def options_format
    unless options.is_a?(Array) && (4..5).include?(options.size)
      errors.add(:options, "must be an array of 4 or 5 items")
    end
  end
end
