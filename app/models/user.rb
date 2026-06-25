class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :subjects, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_many :summaries, dependent: :destroy
  has_many :group_quizzes, dependent: :destroy
  has_many :questions, through: :subjects
end
