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

ActiveRecord::Schema[7.0].define(version: 2023_07_29_021720) do
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

  create_table "annihilations", force: :cascade do |t|
    t.string "game_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "end_time"
  end

  create_table "channels", force: :cascade do |t|
    t.string "title"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.string "thumbnail_url"
    t.string "banner_url"
    t.index ["external_id"], name: "index_channels_on_external_id", unique: true
    t.index ["user_id"], name: "index_channels_on_user_id"
  end

  create_table "clears", force: :cascade do |t|
    t.bigint "submitter_id", null: false
    t.string "link"
    t.bigint "stage_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "channel_id"
    t.index ["channel_id"], name: "index_clears_on_channel_id"
    t.index ["stage_id"], name: "index_clears_on_stage_id"
    t.index ["submitter_id"], name: "index_clears_on_submitter_id"
  end

  create_table "email_verification_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_email_verification_tokens_on_user_id"
  end

  create_table "episodes", force: :cascade do |t|
    t.string "name"
    t.integer "number"
    t.string "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "end_time"
    t.bigint "original_event_id"
    t.index ["original_event_id"], name: "index_events_on_original_event_id"
  end

  create_table "likes", id: false, force: :cascade do |t|
    t.bigint "clear_id", null: false
    t.bigint "user_id", null: false
    t.index ["clear_id"], name: "index_likes_on_clear_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "operators", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "game_id"
    t.integer "rarity"
    t.string "skill_game_ids", array: true
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stages", force: :cascade do |t|
    t.string "game_id"
    t.string "code"
    t.integer "zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stageable_type", null: false
    t.bigint "stageable_id", null: false
    t.index ["stageable_type", "stageable_id"], name: "index_stages_on_stageable"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "used_operators", force: :cascade do |t|
    t.bigint "operator_id", null: false
    t.bigint "clear_id", null: false
    t.integer "skill"
    t.integer "skill_level"
    t.integer "used_module"
    t.integer "module_level"
    t.integer "level"
    t.integer "elite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "skill_mastery"
    t.index ["clear_id"], name: "index_used_operators_on_clear_id"
    t.index ["operator_id"], name: "index_used_operators_on_operator_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "verifications", force: :cascade do |t|
    t.bigint "verifier_id", null: false
    t.bigint "clear_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clear_id"], name: "index_verifications_on_clear_id"
    t.index ["verifier_id"], name: "index_verifications_on_verifier_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "channels", "users"
  add_foreign_key "clears", "channels"
  add_foreign_key "clears", "stages"
  add_foreign_key "clears", "users", column: "submitter_id"
  add_foreign_key "email_verification_tokens", "users"
  add_foreign_key "events", "events", column: "original_event_id"
  add_foreign_key "likes", "clears"
  add_foreign_key "likes", "users"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "used_operators", "clears"
  add_foreign_key "used_operators", "operators"
  add_foreign_key "verifications", "clears"
  add_foreign_key "verifications", "users", column: "verifier_id"
end
