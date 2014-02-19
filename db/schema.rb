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

ActiveRecord::Schema.define(version: 20140218194419) do

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name"

  create_table "events", force: true do |t|
    t.string   "name"
    t.string   "fb_event_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "place_id"
    t.integer  "fee"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["name"], name: "index_events_on_name"
  add_index "events", ["place_id"], name: "index_events_on_place_id"
  add_index "events", ["start_time"], name: "index_events_on_start_time"

  create_table "invitations", force: true do |t|
    t.integer  "event_id"
    t.string   "title"
    t.text     "greeting"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["event_id"], name: "index_invitations_on_event_id"

  create_table "member_relationships", force: true do |t|
    t.integer  "introduced_id"
    t.integer  "introducer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_relationships", ["introduced_id", "introducer_id"], name: "index_member_relationships_on_introduced_id_and_introducer_id", unique: true
  add_index "member_relationships", ["introduced_id"], name: "index_member_relationships_on_introduced_id"
  add_index "member_relationships", ["introducer_id"], name: "index_member_relationships_on_introducer_id"

  create_table "members", force: true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "last_name_kana"
    t.string   "first_name_kana"
    t.string   "email"
    t.integer  "category_id"
    t.string   "affiliation"
    t.string   "title"
    t.string   "note"
    t.string   "fb_name"
    t.string   "fb_user_id"
    t.boolean  "black_list_flg"
    t.boolean  "gtic_flg"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["affiliation"], name: "index_members_on_affiliation"
  add_index "members", ["black_list_flg"], name: "index_members_on_black_list_flg"
  add_index "members", ["category_id"], name: "index_members_on_category_id"
  add_index "members", ["email"], name: "index_members_on_email"
  add_index "members", ["fb_name"], name: "index_members_on_fb_name"
  add_index "members", ["fb_user_id"], name: "index_members_on_fb_user_id"
  add_index "members", ["gtic_flg"], name: "index_members_on_gtic_flg"
  add_index "members", ["last_name"], name: "index_members_on_last_name"
  add_index "members", ["last_name_kana"], name: "index_members_on_last_name_kana"
  add_index "members", ["title"], name: "index_members_on_title"

  create_table "places", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["name"], name: "index_places_on_name"

  create_table "relationships", force: true do |t|
    t.integer  "member_id"
    t.integer  "event_id"
    t.boolean  "presenter_flg", default: false
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["event_id"], name: "index_relationships_on_event_id"
  add_index "relationships", ["member_id", "event_id"], name: "index_relationships_on_member_id_and_event_id", unique: true
  add_index "relationships", ["member_id"], name: "index_relationships_on_member_id"
  add_index "relationships", ["presenter_flg"], name: "index_relationships_on_presenter_flg"
  add_index "relationships", ["status"], name: "index_relationships_on_status"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "provider"
    t.string   "uid"
    t.string   "image_url"
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["access_token"], name: "index_users_on_access_token"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["provider"], name: "index_users_on_provider"
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true

end
