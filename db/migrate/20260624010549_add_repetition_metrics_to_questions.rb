class AddRepetitionMetricsToQuestions < ActiveRecord::Migration[8.1]
  def change
    add_column :questions, :times_answered, :integer, default: 0, null: false
    add_column :questions, :last_answered_at, :datetime
  end
end
