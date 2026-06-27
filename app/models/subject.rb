class Subject < ApplicationRecord
  belongs_to :user
  has_many :summaries, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :exams, dependent: :destroy

  validates :name, presence: true
  validates :color, presence: true

  before_validation :set_defaults, on: :create

  private

  def set_defaults
    self.color ||= "#a78bfa"
    self.icon = "schema" if self.icon.blank?
  end
end
