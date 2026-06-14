class Subject < ApplicationRecord
  belongs_to :user
  has_many :summaries, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :exams, dependent: :destroy

  validates :name, presence: true
end
