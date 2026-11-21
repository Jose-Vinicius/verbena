class CreateStudySourcesAndChunks < ActiveRecord::Migration[8.1]
  def change
    create_table :study_sources do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :source_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.text :raw_text
      t.text :error_message
      t.boolean :selected, null: false, default: true
      t.integer :pages_count, null: false, default: 0
      t.integer :chunks_count, null: false, default: 0
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :study_sources, :deleted_at
    add_index :study_sources, [ :subject_id, :deleted_at ]

    create_table :source_chunks do |t|
      t.references :study_source, null: false, foreign_key: true
      t.integer :position, null: false
      t.text :content, null: false
      t.integer :char_count, null: false, default: 0
      t.integer :used_count, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}
      t.virtual :searchable, type: :tsvector, as: "to_tsvector('portuguese', coalesce(content, ''))", stored: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :source_chunks, :deleted_at
    add_index :source_chunks, :searchable, using: :gin
    add_index :source_chunks, [ :study_source_id, :position ]

    add_column :summaries, :focus_query, :string
    add_column :summaries, :study_source_ids, :jsonb, null: false, default: []
  end
end
