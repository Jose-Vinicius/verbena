class GroupQuiz < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  has_many :group_quiz_questions, dependent: :destroy
  has_many :questions, through: :group_quiz_questions
  has_many :group_participants, dependent: :destroy

  enum :status, { open: 0, closed: 1 }

  validates :title, presence: true
  validates :token, presence: true, uniqueness: true
  validates :questions_count, presence: true, numericality: { greater_than: 0 }

  before_validation :generate_token, on: :create
  before_validation :set_expires_at, on: :create

  scope :active, -> { where(status: :open).where("expires_at > ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def accessible?
    open? && !expired?
  end

  def time_remaining
    [(expires_at - Time.current).to_i, 0].max
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(16)
  end

  def set_expires_at
    self.expires_at ||= 90.minutes.from_now
  end
end
