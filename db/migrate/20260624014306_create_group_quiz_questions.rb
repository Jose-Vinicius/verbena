class CreateGroupQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :group_quiz_questions do |t|
      t.references :group_quiz, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
