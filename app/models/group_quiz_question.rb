class GroupQuizQuestion < ApplicationRecord
  include SoftDeletable

  belongs_to :group_quiz
  belongs_to :question
end
