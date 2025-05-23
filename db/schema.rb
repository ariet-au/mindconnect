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

ActiveRecord::Schema[8.0].define(version: 2025_05_23_223104) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "client_types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "psychological_issues", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "category"
    t.string "severity_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.decimal "standard_rate"
    t.string "currency"
    t.boolean "in_person"
    t.boolean "online"
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "psychologist_client_types", "client_types"
  add_foreign_key "psychologist_client_types", "psychologist_profiles"
  add_foreign_key "psychologist_issues", "issues"
  add_foreign_key "psychologist_issues", "psychologist_profiles"
  add_foreign_key "psychologist_languages", "languages"
  add_foreign_key "psychologist_languages", "psychologist_profiles"
  add_foreign_key "psychologist_profiles", "users"
  add_foreign_key "psychologist_specialties", "psychologist_profiles"
  add_foreign_key "psychologist_specialties", "specialties"
  add_foreign_key "services", "users"
end
