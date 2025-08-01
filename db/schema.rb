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

ActiveRecord::Schema[8.0].define(version: 2025_07_31_233136) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.string "title"
    t.boolean "is_published"
    t.datetime "published_at"
    t.string "slug"
    t.integer "status"
    t.integer "moderated_by_admin_id"
    t.string "moderation_reason"
    t.datetime "moderated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psychologist_profile_id"], name: "index_articles_on_psychologist_profile_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.bigint "service_id"
    t.bigint "client_profile_id"
    t.bigint "internal_client_profile_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "created_by"
    t.string "confirmation_token"
    t.index ["client_profile_id"], name: "index_bookings_on_client_profile_id"
    t.index ["confirmation_token"], name: "index_bookings_on_confirmation_token", unique: true
    t.index ["internal_client_profile_id"], name: "index_bookings_on_internal_client_profile_id"
    t.index ["psychologist_profile_id"], name: "index_bookings_on_psychologist_profile_id"
    t.index ["service_id"], name: "index_bookings_on_service_id"
  end

  create_table "client_profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "dob"
    t.string "gender"
    t.string "country"
    t.string "city"
    t.text "address"
    t.string "timezone"
    t.string "phone_number1"
    t.string "phone_number2"
    t.string "telegram"
    t.string "whatsapp"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_client_profiles_on_user_id", unique: true
  end

  create_table "client_types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_types_issues", id: false, force: :cascade do |t|
    t.bigint "client_type_id", null: false
    t.bigint "issue_id", null: false
    t.index ["client_type_id", "issue_id"], name: "index_client_types_issues_on_client_type_id_and_issue_id", unique: true
    t.index ["client_type_id"], name: "index_client_types_issues_on_client_type_id"
    t.index ["issue_id"], name: "index_client_types_issues_on_issue_id"
  end

  create_table "educations", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.string "degree", null: false
    t.string "institution"
    t.string "field_of_study", null: false
    t.string "graduation_year"
    t.string "certificate_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psychologist_profile_id"], name: "index_educations_on_psychologist_profile_id"
  end

  create_table "internal_client_profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number1"
    t.string "phone_number2"
    t.string "telegram"
    t.string "whatsapp"
    t.string "gender"
    t.date "dob"
    t.string "country"
    t.string "city"
    t.text "address"
    t.string "internal_reference_number"
    t.string "preferred_contact_method"
    t.string "emergency_contact_name"
    t.string "emergency_contact_phone"
    t.string "emergency_contact_relationship"
    t.text "reason_for_referral"
    t.string "gp_name"
    t.text "gp_contact_info"
    t.text "initial_assessment_summary"
    t.text "risk_assessment_summary"
    t.text "treatment_plan_summary"
    t.boolean "first_time_therapy"
    t.integer "status"
    t.bigint "psychologist_profile_id", null: false
    t.bigint "client_profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_profile_id"], name: "index_internal_client_profiles_on_client_profile_id"
    t.index ["psychologist_profile_id", "internal_reference_number"], name: "idx_internal_client_ref_per_psych", unique: true
    t.index ["psychologist_profile_id"], name: "index_internal_client_profiles_on_psychologist_profile_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "category"
    t.string "severity_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_languages_on_name", unique: true
  end

  create_table "progress_notes", force: :cascade do |t|
    t.bigint "therapy_plan_id", null: false
    t.bigint "booking_id"
    t.text "notes"
    t.text "homework_assigned"
    t.integer "assessment_score"
    t.date "note_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_progress_notes_on_booking_id"
    t.index ["therapy_plan_id"], name: "index_progress_notes_on_therapy_plan_id"
  end

  create_table "psychological_issues", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "category"
    t.string "severity_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "psychologist_availabilities", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.integer "day_of_week"
    t.time "start_time_of_day"
    t.time "end_time_of_day"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psychologist_profile_id"], name: "index_psychologist_availabilities_on_psychologist_profile_id"
  end

  create_table "psychologist_client_types", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.bigint "client_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_type_id"], name: "index_psychologist_client_types_on_client_type_id"
    t.index ["psychologist_profile_id"], name: "index_psychologist_client_types_on_psychologist_profile_id"
  end

  create_table "psychologist_issues", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.bigint "issue_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_psychologist_issues_on_issue_id"
    t.index ["psychologist_profile_id"], name: "index_psychologist_issues_on_psychologist_profile_id"
  end

  create_table "psychologist_languages", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.bigint "language_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_psychologist_languages_on_language_id"
    t.index ["psychologist_profile_id"], name: "index_psychologist_languages_on_psychologist_profile_id"
  end

  create_table "psychologist_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "about_me"
    t.string "first_name"
    t.string "last_name"
    t.integer "years_of_experience"
    t.string "license_number"
    t.string "country"
    t.string "city"
    t.string "address"
    t.string "telegram"
    t.string "whatsapp"
    t.string "contact_phone"
    t.string "contact_phone2"
    t.string "contact_phone3"
    t.integer "gender"
    t.string "education"
    t.boolean "is_doctor"
    t.string "is_degree_boolean"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "standard_rate", precision: 10, scale: 2
    t.string "currency"
    t.boolean "in_person"
    t.boolean "online"
    t.text "about_clients"
    t.text "about_issues"
    t.text "about_specialties"
    t.string "primary_contact_method"
    t.string "timezone"
    t.string "status", default: "pending_review", null: false
    t.string "youtube_video_url"
    t.string "profile_url"
    t.string "religion"
    t.bigint "featured_service_id"
    t.index ["featured_service_id"], name: "index_psychologist_profiles_on_featured_service_id"
    t.index ["profile_url"], name: "index_psychologist_profiles_on_profile_url", unique: true
    t.index ["user_id"], name: "index_psychologist_profiles_on_user_id"
  end

  create_table "psychologist_specialties", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.bigint "specialty_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psychologist_profile_id"], name: "index_psychologist_specialties_on_psychologist_profile_id"
    t.index ["specialty_id"], name: "index_psychologist_specialties_on_specialty_id"
  end

  create_table "psychologist_unavailabilities", force: :cascade do |t|
    t.bigint "psychologist_profile_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "reason"
    t.boolean "recurring", default: false
    t.integer "day_of_week"
    t.date "recurring_until"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psychologist_profile_id"], name: "index_psychologist_unavailabilities_on_psychologist_profile_id"
  end

  create_table "question_options", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "label"
    t.integer "score"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_options_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.string "text"
    t.string "input_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_quizzes_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.integer "duration_minutes"
    t.integer "delivery_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency", limit: 3
    t.index ["user_id"], name: "index_services_on_user_id"
  end

  create_table "specialties", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "therapy_plans", force: :cascade do |t|
    t.bigint "internal_client_profile_id", null: false
    t.bigint "issue_id"
    t.bigint "specialties_id"
    t.text "diagnosis"
    t.text "short_term_goals"
    t.text "long_term_goals"
    t.text "intervention_details"
    t.string "frequency"
    t.integer "duration_weeks"
    t.text "progress_metrics"
    t.string "status", default: "draft", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["internal_client_profile_id"], name: "index_therapy_plans_on_internal_client_profile_id"
    t.index ["issue_id"], name: "index_therapy_plans_on_issue_id"
    t.index ["specialties_id"], name: "index_therapy_plans_on_specialties_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "phone"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "psychologist_profiles"
  add_foreign_key "bookings", "client_profiles"
  add_foreign_key "bookings", "internal_client_profiles"
  add_foreign_key "bookings", "psychologist_profiles"
  add_foreign_key "bookings", "services"
  add_foreign_key "client_profiles", "users"
  add_foreign_key "client_types_issues", "client_types"
  add_foreign_key "client_types_issues", "issues"
  add_foreign_key "educations", "psychologist_profiles"
  add_foreign_key "internal_client_profiles", "client_profiles"
  add_foreign_key "internal_client_profiles", "psychologist_profiles"
  add_foreign_key "progress_notes", "bookings"
  add_foreign_key "progress_notes", "therapy_plans"
  add_foreign_key "psychologist_availabilities", "psychologist_profiles"
  add_foreign_key "psychologist_client_types", "client_types"
  add_foreign_key "psychologist_client_types", "psychologist_profiles"
  add_foreign_key "psychologist_issues", "issues"
  add_foreign_key "psychologist_issues", "psychologist_profiles"
  add_foreign_key "psychologist_languages", "languages"
  add_foreign_key "psychologist_languages", "psychologist_profiles"
  add_foreign_key "psychologist_profiles", "services", column: "featured_service_id"
  add_foreign_key "psychologist_profiles", "users"
  add_foreign_key "psychologist_specialties", "psychologist_profiles"
  add_foreign_key "psychologist_specialties", "specialties"
  add_foreign_key "psychologist_unavailabilities", "psychologist_profiles"
  add_foreign_key "question_options", "questions"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "quizzes", "users"
  add_foreign_key "services", "users"
  add_foreign_key "therapy_plans", "internal_client_profiles"
  add_foreign_key "therapy_plans", "issues"
  add_foreign_key "therapy_plans", "specialties", column: "specialties_id"
end
