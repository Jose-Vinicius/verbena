# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_21_140300) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "exam_questions", force: :cascade do |t|
    t.integer "chosen_index"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "exam_id", null: false
    t.boolean "is_correct"
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_exam_questions_on_deleted_at"
    t.index ["exam_id"], name: "index_exam_questions_on_exam_id"
    t.index ["question_id"], name: "index_exam_questions_on_question_id"
  end

  create_table "exams", force: :cascade do |t|
    t.integer "correct_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "questions_count", null: false
    t.integer "status", default: 0, null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["deleted_at"], name: "index_exams_on_deleted_at"
    t.index ["subject_id"], name: "index_exams_on_subject_id"
    t.index ["user_id"], name: "index_exams_on_user_id"
  end

  create_table "group_answers", force: :cascade do |t|
    t.integer "chosen_index"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "group_participant_id", null: false
    t.boolean "is_correct"
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_group_answers_on_deleted_at"
    t.index ["group_participant_id"], name: "index_group_answers_on_group_participant_id"
    t.index ["question_id"], name: "index_group_answers_on_question_id"
  end

  create_table "group_participants", force: :cascade do |t|
    t.integer "correct_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "group_quiz_id", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_group_participants_on_deleted_at"
    t.index ["group_quiz_id"], name: "index_group_participants_on_group_quiz_id"
    t.index ["token"], name: "index_group_participants_on_token", unique: true
  end

  create_table "group_quiz_questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "group_quiz_id", null: false
    t.integer "position"
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_group_quiz_questions_on_deleted_at"
    t.index ["group_quiz_id"], name: "index_group_quiz_questions_on_group_quiz_id"
    t.index ["question_id"], name: "index_group_quiz_questions_on_question_id"
  end

  create_table "group_quizzes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "expires_at", null: false
    t.integer "questions_count", null: false
    t.integer "status", default: 0, null: false
    t.bigint "subject_id", null: false
    t.string "title", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["deleted_at"], name: "index_group_quizzes_on_deleted_at"
    t.index ["subject_id"], name: "index_group_quizzes_on_subject_id"
    t.index ["token"], name: "index_group_quizzes_on_token", unique: true
    t.index ["user_id"], name: "index_group_quizzes_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "correct_index"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "explanation"
    t.datetime "last_answered_at"
    t.jsonb "options"
    t.text "statement"
    t.bigint "subject_id", null: false
    t.bigint "summary_id", null: false
    t.integer "times_answered", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_questions_on_deleted_at"
    t.index ["subject_id"], name: "index_questions_on_subject_id"
    t.index ["summary_id"], name: "index_questions_on_summary_id"
  end

  create_table "source_chunks", force: :cascade do |t|
    t.integer "char_count", default: 0, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.jsonb "metadata", default: {}, null: false
    t.integer "position", null: false
    t.virtual "searchable", type: :tsvector, as: "to_tsvector('portuguese'::regconfig, COALESCE(content, ''::text))", stored: true
    t.bigint "study_source_id", null: false
    t.datetime "updated_at", null: false
    t.integer "used_count", default: 0, null: false
    t.index ["deleted_at"], name: "index_source_chunks_on_deleted_at"
    t.index ["searchable"], name: "index_source_chunks_on_searchable", using: :gin
    t.index ["study_source_id", "position"], name: "index_source_chunks_on_study_source_id_and_position"
    t.index ["study_source_id"], name: "index_source_chunks_on_study_source_id"
  end

  create_table "study_sources", force: :cascade do |t|
    t.integer "chunks_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "error_message"
    t.integer "pages_count", default: 0, null: false
    t.text "raw_text"
    t.boolean "selected", default: true, null: false
    t.integer "source_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.bigint "subject_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["deleted_at"], name: "index_study_sources_on_deleted_at"
    t.index ["subject_id", "deleted_at"], name: "index_study_sources_on_subject_id_and_deleted_at"
    t.index ["subject_id"], name: "index_study_sources_on_subject_id"
    t.index ["user_id"], name: "index_study_sources_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "icon"
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["deleted_at"], name: "index_subjects_on_deleted_at"
    t.index ["user_id"], name: "index_subjects_on_user_id"
  end

  create_table "summaries", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "focus_query"
    t.integer "questions_requested"
    t.integer "status"
    t.jsonb "study_source_ids", default: [], null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["deleted_at"], name: "index_summaries_on_deleted_at"
    t.index ["subject_id"], name: "index_summaries_on_subject_id"
    t.index ["user_id"], name: "index_summaries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "custom_prompt"
    t.datetime "deleted_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "gemini_model", default: "gemini-2.5-flash"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "exam_questions", "exams"
  add_foreign_key "exam_questions", "questions"
  add_foreign_key "exams", "subjects"
  add_foreign_key "exams", "users"
  add_foreign_key "group_answers", "group_participants"
  add_foreign_key "group_answers", "questions"
  add_foreign_key "group_participants", "group_quizzes"
  add_foreign_key "group_quiz_questions", "group_quizzes"
  add_foreign_key "group_quiz_questions", "questions"
  add_foreign_key "group_quizzes", "subjects"
  add_foreign_key "group_quizzes", "users"
  add_foreign_key "questions", "subjects"
  add_foreign_key "questions", "summaries"
  add_foreign_key "source_chunks", "study_sources"
  add_foreign_key "study_sources", "subjects"
  add_foreign_key "study_sources", "users"
  add_foreign_key "subjects", "users"
  add_foreign_key "summaries", "subjects"
  add_foreign_key "summaries", "users"
end
