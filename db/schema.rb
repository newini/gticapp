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

ActiveRecord::Schema.define(version: 20140123151949) do

  create_table "connections", force: true do |t|
    t.integer  "invited_event_id"
    t.integer  "invited_member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["invited_event_id", "invited_member_id"], name: "index_connections_on_invited_event_id_and_invited_member_id", unique: true
  add_index "connections", ["invited_event_id"], name: "index_connections_on_invited_event_id"
  add_index "connections", ["invited_member_id"], name: "index_connections_on_invited_member_id"

  create_table "events", force: true do |t|
    t.string   "name"
    t.integer  "num_of_participants"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.datetime "start_time"
    t.string   "place"
    t.integer  "fee"
  end

  add_index "events", ["date"], name: "index_events_on_date"
  add_index "events", ["name"], name: "index_events_on_name"
  add_index "events", ["num_of_participants"], name: "index_events_on_num_of_participants"
  add_index "events", ["url"], name: "index_events_on_url"

  create_table "invitations", force: true do |t|
    t.integer  "event_id"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "greeting"
  end

  add_index "invitations", ["event_id"], name: "index_invitations_on_event_id"

  create_table "members", force: true do |t|
    t.string   "name"
    t.string   "name_kana"
    t.string   "email"
    t.string   "affiliation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_name"
    t.boolean  "black_list_flg", default: false
  end

  add_index "members", ["affiliation"], name: "index_members_on_affiliation"
  add_index "members", ["black_list_flg"], name: "index_members_on_black_list_flg"
  add_index "members", ["email"], name: "index_members_on_email"
  add_index "members", ["facebook_name"], name: "index_members_on_facebook_name"
  add_index "members", ["name_kana"], name: "index_members_on_name_kana"

  create_table "relationships", force: true do |t|
    t.integer  "participated_id"
    t.integer  "participant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "presenter_flg",   default: false
  end

  add_index "relationships", ["participant_id"], name: "index_relationships_on_participant_id"
  add_index "relationships", ["participated_id", "participant_id"], name: "index_relationships_on_participated_id_and_participant_id", unique: true
  add_index "relationships", ["participated_id"], name: "index_relationships_on_participated_id"
  add_index "relationships", ["presenter_flg"], name: "index_relationships_on_presenter_flg"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.string   "password_digest"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
