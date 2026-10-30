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

ActiveRecord::Schema[8.1].define(version: 2026_10_29_230000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", force: :cascade do |t|
    t.bigint "organizer_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "venue", null: false
    t.datetime "starts_at", null: false
    t.integer "total_capacity", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
    t.check_constraint "status = ANY (ARRAY[0, 1, 2])", name: "events_status_valid"
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
    t.bigint "user_id", null: false
    t.bigint "ticket_tier_id", null: false
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_tier_id"], name: "index_tickets_on_ticket_tier_id"
    t.index ["user_id", "ticket_tier_id"], name: "index_tickets_on_user_id_and_ticket_tier_id", unique: true
    t.index ["user_id"], name: "index_tickets_on_user_id"
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

  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "ticket_tiers", "events"
  add_foreign_key "tickets", "ticket_tiers"
  add_foreign_key "tickets", "users"
end
