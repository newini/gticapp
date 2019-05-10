# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190510035641) do

  create_table "accounts", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.float    "amount"
    t.integer  "event_id"
    t.boolean  "positive"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["amount"], name: "index_accounts_on_amount"
  add_index "accounts", ["event_id"], name: "index_accounts_on_event_id"
  add_index "accounts", ["positive"], name: "index_accounts_on_positive"
  add_index "accounts", ["title"], name: "index_accounts_on_title"

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name"

  create_table "event_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "fb_event_id",       limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "place_id"
    t.integer  "fee"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_category_id"
    t.string   "note",              limit: 255
  end

  add_index "events", ["event_category_id"], name: "index_events_on_event_category_id"
  add_index "events", ["name"], name: "index_events_on_name"
  add_index "events", ["place_id"], name: "index_events_on_place_id"
  add_index "events", ["start_time"], name: "index_events_on_start_time"

  create_table "invitations", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "title",      limit: 255
    t.text     "greeting"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["event_id"], name: "index_invitations_on_event_id"

  create_table "member_relationships", force: :cascade do |t|
    t.integer  "introduced_id"
    t.integer  "introducer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_relationships", ["introduced_id", "introducer_id"], name: "index_member_relationships_on_introduced_id_and_introducer_id", unique: true
  add_index "member_relationships", ["introduced_id"], name: "index_member_relationships_on_introduced_id"
  add_index "member_relationships", ["introducer_id"], name: "index_member_relationships_on_introducer_id"

  create_table "members", force: :cascade do |t|
    t.string   "last_name",           limit: 255
    t.string   "first_name",          limit: 255
    t.string   "last_name_alphabet",  limit: 255
    t.string   "first_name_alphabet", limit: 255
    t.string   "email",               limit: 255
    t.integer  "category_id"
    t.string   "affiliation",         limit: 255
    t.string   "title",               limit: 255
    t.string   "note",                limit: 255
    t.string   "fb_name",             limit: 255
    t.string   "fb_user_id",          limit: 255
    t.boolean  "black_list_flg"
    t.boolean  "gtic_flg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "birthday"
    t.boolean  "past_presenter_flg",              default: false
    t.boolean  "azsa_flg",                        default: false
  end

  add_index "members", ["affiliation"], name: "index_members_on_affiliation"
  add_index "members", ["birthday"], name: "index_members_on_birthday"
  add_index "members", ["black_list_flg"], name: "index_members_on_black_list_flg"
  add_index "members", ["category_id"], name: "index_members_on_category_id"
  add_index "members", ["email"], name: "index_members_on_email"
  add_index "members", ["fb_name"], name: "index_members_on_fb_name"
  add_index "members", ["fb_user_id"], name: "index_members_on_fb_user_id"
  add_index "members", ["gtic_flg"], name: "index_members_on_gtic_flg"
  add_index "members", ["last_name"], name: "index_members_on_last_name"
  add_index "members", ["last_name_alphabet"], name: "index_members_on_last_name_alphabet"
  add_index "members", ["title"], name: "index_members_on_title"

  create_table "places", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "address",    limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["name"], name: "index_places_on_name"

  create_table "presentations", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "event_id"
    t.string   "title",      limit: 255
    t.string   "abstract",   limit: 255
    t.string   "note",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "presentations", ["event_id"], name: "index_presentations_on_event_id"
  add_index "presentations", ["member_id"], name: "index_presentations_on_member_id"
  add_index "presentations", ["title"], name: "index_presentations_on_title"

  create_table "presentationships", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "event_id"
    t.integer  "presentation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "presentationships", ["event_id"], name: "index_presentationships_on_event_id"
  add_index "presentationships", ["member_id", "event_id", "presentation_id"], name: "presentationship_index", unique: true
  add_index "presentationships", ["member_id"], name: "index_presentationships_on_member_id"
  add_index "presentationships", ["presentation_id"], name: "index_presentationships_on_presentation_id"

  create_table "registers", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "account_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registers", ["account_id"], name: "index_registers_on_account_id"
  add_index "registers", ["amount"], name: "index_registers_on_amount"
  add_index "registers", ["event_id"], name: "index_registers_on_event_id"

  create_table "relationships", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "event_id"
    t.integer  "presentation_role",             default: 0
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest_flg"
    t.string   "note",              limit: 255
  end

  add_index "relationships", ["event_id"], name: "index_relationships_on_event_id"
  add_index "relationships", ["guest_flg"], name: "index_relationships_on_guest_flg"
  add_index "relationships", ["member_id", "event_id"], name: "index_relationships_on_member_id_and_event_id", unique: true
  add_index "relationships", ["member_id"], name: "index_relationships_on_member_id"
  add_index "relationships", ["note"], name: "index_relationships_on_note"
  add_index "relationships", ["presentation_role"], name: "index_relationships_on_presentation_role"
  add_index "relationships", ["status"], name: "index_relationships_on_status"

  create_table "schedule_logs", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "member_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedule_logs", ["event_id"], name: "index_schedule_logs_on_event_id"
  add_index "schedule_logs", ["member_id"], name: "index_schedule_logs_on_member_id"
  add_index "schedule_logs", ["status"], name: "index_schedule_logs_on_status"

  create_table "users", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "password",        limit: 255
    t.string   "password_digest", limit: 255
    t.string   "remember_token",  limit: 255
    t.string   "provider",        limit: 255
    t.string   "uid",             limit: 255
    t.string   "image_url",       limit: 255
    t.string   "access_token",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.integer  "member_id"
    t.boolean  "active_flg"
    t.string   "description"
  end

  add_index "users", ["access_token"], name: "index_users_on_access_token"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["provider"], name: "index_users_on_provider"
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true

end
