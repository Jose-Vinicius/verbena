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

ActiveRecord::Schema[8.1].define(version: 2026_06_24_014330) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "exam_questions", force: :cascade do |t|
    t.integer "chosen_index"
    t.datetime "created_at", null: false
    t.bigint "exam_id", null: false
    t.boolean "is_correct"
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_id"], name: "index_exam_questions_on_exam_id"
    t.index ["question_id"], name: "index_exam_questions_on_question_id"
  end

  create_table "exams", force: :cascade do |t|
    t.integer "correct_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "questions_count", null: false
    t.integer "status", default: 0, null: false
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["subject_id"], name: "index_exams_on_subject_id"
    t.index ["user_id"], name: "index_exams_on_user_id"
  end

  create_table "group_answers", force: :cascade do |t|
    t.integer "chosen_index"
    t.datetime "created_at", null: false
    t.bigint "group_participant_id", null: false
    t.boolean "is_correct"
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_participant_id"], name: "index_group_answers_on_group_participant_id"
    t.index ["question_id"], name: "index_group_answers_on_question_id"
  end

  create_table "group_participants", force: :cascade do |t|
    t.integer "correct_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "group_quiz_id", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["group_quiz_id"], name: "index_group_participants_on_group_quiz_id"
    t.index ["token"], name: "index_group_participants_on_token", unique: true
  end

  create_table "group_quiz_questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_quiz_id", null: false
    t.integer "position"
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_quiz_id"], name: "index_group_quiz_questions_on_group_quiz_id"
    t.index ["question_id"], name: "index_group_quiz_questions_on_question_id"
  end

  create_table "group_quizzes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "questions_count", null: false
    t.integer "status", default: 0, null: false
    t.bigint "subject_id", null: false
    t.string "title", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
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
    t.index ["subject_id"], name: "index_questions_on_subject_id"
    t.index ["summary_id"], name: "index_questions_on_summary_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_subjects_on_user_id"
  end

  create_table "summaries", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "questions_requested"
    t.integer "status"
    t.bigint "subject_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["subject_id"], name: "index_summaries_on_subject_id"
    t.index ["user_id"], name: "index_summaries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

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
  add_foreign_key "subjects", "users"
  add_foreign_key "summaries", "subjects"
  add_foreign_key "summaries", "users"
end
