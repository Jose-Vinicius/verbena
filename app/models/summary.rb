class Summary < ApplicationRecord
  belongs_to :user
  belongs_to :subject

  enum :status, { pending: 0, processing: 1, done: 2, error: 3 }, default: :pending

  validates :content, presence: true, length: { maximum: 10_000 }
  validates :questions_requested, presence: true, inclusion: { in: [10, 20, 30] }

  after_update_commit -> { broadcast_replace_to [user, "summaries"], target: "summary_#{id}", partial: "summaries/status", locals: { summary: self } }
end
