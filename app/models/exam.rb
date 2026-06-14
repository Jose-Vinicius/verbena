class Exam < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  has_many :exam_questions, dependent: :destroy
  has_many :questions, through: :exam_questions

  enum :status, { in_progress: 0, finished: 1 }

  validates :questions_count, presence: true, numericality: { greater_than: 0 }
  validates :correct_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
