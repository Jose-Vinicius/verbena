class GroupAnswer < ApplicationRecord
  include SoftDeletable

  belongs_to :group_participant
  belongs_to :question
end
