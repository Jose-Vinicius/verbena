class AddDeletedAtToAllTables < ActiveRecord::Migration[8.1]
  TABLES = %i[
    subjects
    summaries
    exams
    exam_questions
    group_quizzes
    group_quiz_questions
    group_participants
    group_answers
    users
  ].freeze

  def change
    TABLES.each do |table|
      add_column table, :deleted_at, :datetime
      add_index table, :deleted_at
    end

    add_index :questions, :deleted_at unless index_exists?(:questions, :deleted_at)
  end
end
