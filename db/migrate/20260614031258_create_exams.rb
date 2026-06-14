class CreateExams < ActiveRecord::Migration[8.1]
  def change
    create_table :exams do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.integer :questions_count, null: false
      t.integer :correct_count, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
