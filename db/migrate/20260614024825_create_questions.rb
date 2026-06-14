class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.references :summary, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.text :statement
      t.jsonb :options
      t.integer :correct_index
      t.text :explanation

      t.timestamps
    end
  end
end
