class CreateSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :summaries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.text :content
      t.integer :questions_requested
      t.integer :status

      t.timestamps
    end
  end
end
