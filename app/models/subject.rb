class Subject < ApplicationRecord
  belongs_to :user
  has_many :summaries, dependent: :destroy

  validates :name, presence: true
end
