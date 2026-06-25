class CreateGroupQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :group_quizzes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.string :title, null: false
      t.string :token, null: false
      t.integer :status, default: 0, null: false
      t.integer :questions_count, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :group_quizzes, :token, unique: true
  end
end
