class GroupAnswer < ApplicationRecord
  belongs_to :group_participant
  belongs_to :question
end
