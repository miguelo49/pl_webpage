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

ActiveRecord::Schema[7.2].define(version: 2026_08_29_145109) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["user_id", "event_id"], name: "index_attendances_on_user_and_event", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "bookmarkable_type", null: false
    t.bigint "bookmarkable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bookmarkable_type", "bookmarkable_id"], name: "index_bookmarks_on_bookmarkable"
    t.index ["user_id", "bookmarkable_type", "bookmarkable_id"], name: "index_bookmarks_on_user_and_bookmarkable", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "user_id", null: false
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.bigint "parent_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "communes", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "region_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id", "name"], name: "index_communes_on_region_id_and_name", unique: true
    t.index ["region_id"], name: "index_communes_on_region_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "location"
    t.datetime "start_at", null: false
    t.bigint "organizer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "end_at"
    t.integer "event_type", default: 0, null: false
    t.bigint "commune_id"
    t.integer "capacity"
    t.index ["commune_id"], name: "index_events_on_commune_id"
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
    t.index ["start_at"], name: "index_events_on_start_at"
  end

  create_table "news", force: :cascade do |t|
    t.string "title", null: false
    t.text "summary", null: false
    t.text "body", null: false
    t.integer "category", null: false
    t.bigint "user_id", null: false
    t.datetime "published_at"
    t.integer "status", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "thread_id"
    t.index ["thread_id"], name: "index_news_on_thread_id"
    t.index ["user_id"], name: "index_news_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "reactable_type", null: false
    t.bigint "reactable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reactable_type", "reactable_id"], name: "index_reactions_on_reactable"
    t.index ["user_id", "reactable_type", "reactable_id"], name: "index_reactions_on_user_and_reactable", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "read_marks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "training_material_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["training_material_id"], name: "index_read_marks_on_training_material_id"
    t.index ["user_id", "training_material_id"], name: "index_read_marks_on_user_and_training_material", unique: true
    t.index ["user_id"], name: "index_read_marks_on_user_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_regions_on_name", unique: true
  end

  create_table "threads", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.bigint "topic_id", null: false
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_threads_on_topic_id"
    t.index ["user_id"], name: "index_threads_on_user_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_topics_on_slug", unique: true
  end

  create_table "training_categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_training_categories_on_name", unique: true
  end

  create_table "training_materials", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "author", null: false
    t.date "date", null: false
    t.bigint "training_category_id", null: false
    t.string "tags", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["training_category_id"], name: "index_training_materials_on_training_category_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "terms_accepted_at"
    t.bigint "residence_commune_id"
    t.bigint "work_commune_id"
    t.bigint "study_commune_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["residence_commune_id"], name: "index_users_on_residence_commune_id"
    t.index ["study_commune_id"], name: "index_users_on_study_commune_id"
    t.index ["work_commune_id"], name: "index_users_on_work_commune_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "events"
  add_foreign_key "attendances", "users"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "users"
  add_foreign_key "communes", "regions"
  add_foreign_key "events", "communes"
  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "news", "threads"
  add_foreign_key "news", "users"
  add_foreign_key "reactions", "users"
  add_foreign_key "read_marks", "training_materials"
  add_foreign_key "read_marks", "users"
  add_foreign_key "threads", "topics"
  add_foreign_key "threads", "users"
  add_foreign_key "training_materials", "training_categories"
  add_foreign_key "users", "communes", column: "residence_commune_id"
  add_foreign_key "users", "communes", column: "study_commune_id"
  add_foreign_key "users", "communes", column: "work_commune_id"
end
