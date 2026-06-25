class GroupParticipant < ApplicationRecord
  belongs_to :group_quiz
  has_many :group_answers, dependent: :destroy

  enum :status, { in_progress: 0, finished: 1 }

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(16)
  end
end
