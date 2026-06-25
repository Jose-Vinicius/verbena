class GroupQuizQuestion < ApplicationRecord
  belongs_to :group_quiz
  belongs_to :question
end
