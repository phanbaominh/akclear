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

ActiveRecord::Schema[7.1].define(version: 2024_01_31_153126) do
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
    t.string "uploads_playlist_id"
    t.integer "clear_language"
    t.index ["external_id"], name: "index_channels_on_external_id", unique: true
    t.index ["user_id"], name: "index_channels_on_user_id"
  end

  create_table "clear_test_cases", force: :cascade do |t|
    t.bigint "clear_id", null: false
    t.string "video_url"
    t.jsonb "used_operators_data"
    t.index ["clear_id"], name: "index_clear_test_cases_on_clear_id"
  end

  create_table "clear_test_runs", force: :cascade do |t|
    t.bigint "test_case_ids", array: true
    t.jsonb "data"
    t.jsonb "configuration"
    t.string "name"
    t.text "note"
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
    t.index ["link", "stage_id"], name: "index_clears_on_link_and_stage_id", unique: true
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
    t.datetime "start_time"
    t.index ["original_event_id"], name: "index_events_on_original_event_id"
  end

  create_table "extract_clear_data_from_video_jobs", force: :cascade do |t|
    t.integer "status"
    t.jsonb "data"
    t.string "video_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "stage_id", null: false
    t.bigint "channel_id"
    t.boolean "operator_name_only", default: true, null: false
    t.index ["channel_id"], name: "index_extract_clear_data_from_video_jobs_on_channel_id"
    t.index ["stage_id"], name: "index_extract_clear_data_from_video_jobs_on_stage_id"
    t.index ["video_url"], name: "index_extract_clear_data_from_video_jobs_on_video_url", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "likes", id: false, force: :cascade do |t|
    t.bigint "clear_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.index ["clear_id"], name: "index_likes_on_clear_id"
    t.index ["created_at"], name: "index_likes_on_created_at"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "mobility_string_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.string "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_string_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_string_translations_on_keys", unique: true
    t.index ["translatable_type", "key", "value", "locale"], name: "index_mobility_string_translations_on_query_keys"
  end

  create_table "mobility_text_translations", force: :cascade do |t|
    t.string "locale", null: false
    t.string "key", null: false
    t.text "value"
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translatable_id", "translatable_type", "key"], name: "index_mobility_text_translations_on_translatable_attribute"
    t.index ["translatable_id", "translatable_type", "locale", "key"], name: "index_mobility_text_translations_on_keys", unique: true
  end

  create_table "operators", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "game_id"
    t.integer "rarity"
    t.string "skill_game_ids", array: true
    t.string "skill_icon_ids", default: [], array: true
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "clear_id"
    t.datetime "created_at", null: false
    t.index ["clear_id"], name: "index_reports_on_clear_id"
    t.index ["created_at"], name: "index_reports_on_created_at"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
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

  create_table "used_operator_verifications", force: :cascade do |t|
    t.bigint "verification_id", null: false
    t.bigint "used_operator_id", null: false
    t.integer "status"
    t.index ["used_operator_id"], name: "index_used_operator_verifications_on_used_operator_id"
    t.index ["verification_id"], name: "index_used_operator_verifications_on_verification_id"
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
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "verifications", force: :cascade do |t|
    t.bigint "verifier_id", null: false
    t.bigint "clear_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.text "comment"
    t.index ["clear_id"], name: "index_verifications_on_clear_id"
    t.index ["verifier_id"], name: "index_verifications_on_verifier_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "channels", "users"
  add_foreign_key "clear_test_cases", "clears"
  add_foreign_key "clears", "channels"
  add_foreign_key "clears", "stages"
  add_foreign_key "clears", "users", column: "submitter_id"
  add_foreign_key "email_verification_tokens", "users"
  add_foreign_key "events", "events", column: "original_event_id"
  add_foreign_key "extract_clear_data_from_video_jobs", "channels"
  add_foreign_key "extract_clear_data_from_video_jobs", "stages"
  add_foreign_key "likes", "clears"
  add_foreign_key "likes", "users"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "reports", "clears"
  add_foreign_key "reports", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "taggings", "tags"
  add_foreign_key "used_operator_verifications", "used_operators"
  add_foreign_key "used_operator_verifications", "verifications"
  add_foreign_key "used_operators", "clears"
  add_foreign_key "used_operators", "operators"
  add_foreign_key "verifications", "clears"
  add_foreign_key "verifications", "users", column: "verifier_id"
end
