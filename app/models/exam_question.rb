class ExamQuestion < ApplicationRecord
  belongs_to :exam
  belongs_to :question

  validates :chosen_index, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }, allow_nil: true
end
