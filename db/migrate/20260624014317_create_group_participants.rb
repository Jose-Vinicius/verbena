class CreateGroupParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :group_participants do |t|
      t.references :group_quiz, null: false, foreign_key: true
      t.string :name, null: false
      t.string :token, null: false
      t.integer :correct_count, default: 0, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :group_participants, :token, unique: true
  end
end
