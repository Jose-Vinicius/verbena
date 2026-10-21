class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  has_many :subjects, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_many :summaries, dependent: :destroy
  has_many :group_quizzes, dependent: :destroy
  has_many :questions, through: :subjects

  validates :gemini_model, inclusion: { in: GeminiClient::MODELS }, allow_blank: true
  validates :custom_prompt, length: { maximum: 30_000 }, allow_blank: true

  def effective_gemini_model
    gemini_model.presence || GeminiClient::DEFAULT_MODEL
  end

  def effective_prompt
    custom_prompt.presence || GeminiClient.default_prompt
  end
end
