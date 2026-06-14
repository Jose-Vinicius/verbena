class CreateExamQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :exam_questions do |t|
      t.references :exam, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :chosen_index
      t.boolean :is_correct

      t.timestamps
    end
  end
end
