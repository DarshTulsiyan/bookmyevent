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

ActiveRecord::Schema[8.1].define(version: 2026_11_14_205047) do
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

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_bookings_on_event_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "organizer_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "venue", null: false
    t.datetime "starts_at", null: false
    t.integer "total_capacity", null: false
    t.integer "status", default: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "rejection_reason"
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2, 3])", name: "events_status_valid"
    t.check_constraint "total_capacity > 0", name: "events_total_capacity_positive"
  end

  create_table "ticket_tiers", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.integer "capacity", null: false
    t.integer "tickets_sold", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "name"], name: "index_ticket_tiers_on_event_id_and_name", unique: true
    t.index ["event_id"], name: "index_ticket_tiers_on_event_id"
    t.check_constraint "capacity > 0", name: "ticket_tiers_capacity_positive"
    t.check_constraint "tickets_sold >= 0 AND tickets_sold <= capacity", name: "ticket_tiers_tickets_sold_within_capacity"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "ticket_tier_id", null: false
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "booking_id", null: false
    t.index ["booking_id"], name: "index_tickets_on_booking_id"
    t.index ["ticket_tier_id"], name: "index_tickets_on_ticket_tier_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.boolean "suspended", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.check_constraint "role = ANY (ARRAY[0, 1, 2])", name: "users_role_valid"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "events"
  add_foreign_key "bookings", "users"
  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "ticket_tiers", "events"
  add_foreign_key "tickets", "bookings"
  add_foreign_key "tickets", "ticket_tiers"
end
