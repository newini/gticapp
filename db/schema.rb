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

ActiveRecord::Schema.define(version: 20140111180115) do

  create_table "events", force: true do |t|
    t.string   "name"
    t.integer  "num_of_participants"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  add_index "events", ["date"], name: "index_events_on_date"
  add_index "events", ["name"], name: "index_events_on_name"
  add_index "events", ["num_of_participants"], name: "index_events_on_num_of_participants"
  add_index "events", ["url"], name: "index_events_on_url"

  create_table "members", force: true do |t|
    t.string   "name"
    t.string   "name_kana"
    t.string   "email"
    t.string   "affiliation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_name"
  end

  add_index "members", ["affiliation"], name: "index_members_on_affiliation"
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

end
