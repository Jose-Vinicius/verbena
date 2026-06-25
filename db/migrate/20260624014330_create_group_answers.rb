class CreateGroupAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :group_answers do |t|
      t.references :group_participant, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :chosen_index
      t.boolean :is_correct

      t.timestamps
    end
  end
end
