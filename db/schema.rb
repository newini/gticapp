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

ActiveRecord::Schema.define(version: 2021_03_03_123859) do

  create_table "accounts", force: :cascade do |t|
    t.string "title", limit: 255
    t.float "amount"
    t.integer "event_id"
    t.boolean "positive"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["amount"], name: "index_accounts_on_amount"
    t.index ["event_id"], name: "index_accounts_on_event_id"
    t.index ["positive"], name: "index_accounts_on_positive"
    t.index ["title"], name: "index_accounts_on_title"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_categories_on_name"
  end

  create_table "event_categories", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "fb_event_id", limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "place_id"
    t.integer "fee"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_category_id"
    t.string "note"
    t.integer "cumulative_number"
    t.index ["event_category_id"], name: "index_events_on_event_category_id"
    t.index ["name"], name: "index_events_on_name"
    t.index ["place_id"], name: "index_events_on_place_id"
    t.index ["start_time"], name: "index_events_on_start_time"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "event_id", default: 0
    t.string "title", limit: 255
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "sent_flg"
    t.boolean "include_gtic_flg", default: false
    t.datetime "sent_at"
    t.boolean "include_all_flg", default: false
    t.integer "birth_month", default: 0
    t.integer "sent_cnt"
    t.string "emails"
    t.index ["event_id"], name: "index_invitations_on_event_id"
  end

  create_table "media_articles", force: :cascade do |t|
    t.string "media"
    t.string "url"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_path"
    t.datetime "date"
    t.integer "member_id"
  end

  create_table "member_invitation_relationships", force: :cascade do |t|
    t.integer "member_id"
    t.integer "invitation_id"
    t.boolean "sent_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "include_all_flg", default: false
    t.boolean "include_gtic_flg", default: false
    t.integer "birth_month", default: 0
    t.integer "event_id", default: 0
  end

  create_table "member_relationships", force: :cascade do |t|
    t.integer "introduced_id"
    t.integer "introducer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["introduced_id", "introducer_id"], name: "index_member_relationships_on_introduced_id_and_introducer_id", unique: true
    t.index ["introduced_id"], name: "index_member_relationships_on_introduced_id"
    t.index ["introducer_id"], name: "index_member_relationships_on_introducer_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "last_name", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name_alphabet", limit: 255
    t.string "first_name_alphabet", limit: 255
    t.string "email", limit: 255
    t.integer "category_id"
    t.string "affiliation", limit: 255
    t.string "title", limit: 255
    t.string "note", limit: 255
    t.string "fb_name", limit: 255
    t.string "fb_user_id", limit: 255
    t.boolean "black_list_flg"
    t.boolean "gtic_flg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "birthday"
    t.boolean "past_presenter_flg", default: false
    t.boolean "azsa_flg", default: false
    t.boolean "contributor_flg", default: false
    t.integer "age"
    t.integer "gender"
    t.index ["affiliation"], name: "index_members_on_affiliation"
    t.index ["birthday"], name: "index_members_on_birthday"
    t.index ["black_list_flg"], name: "index_members_on_black_list_flg"
    t.index ["category_id"], name: "index_members_on_category_id"
    t.index ["email"], name: "index_members_on_email"
    t.index ["fb_name"], name: "index_members_on_fb_name"
    t.index ["fb_user_id"], name: "index_members_on_fb_user_id"
    t.index ["gtic_flg"], name: "index_members_on_gtic_flg"
    t.index ["last_name"], name: "index_members_on_last_name"
    t.index ["last_name_alphabet"], name: "index_members_on_last_name_alphabet"
    t.index ["title"], name: "index_members_on_title"
  end

  create_table "places", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "address", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_places_on_name"
  end

  create_table "presentations", force: :cascade do |t|
    t.integer "member_id"
    t.integer "event_id"
    t.string "title", limit: 255
    t.string "abstract", limit: 255
    t.string "note", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_presentations_on_event_id"
    t.index ["member_id"], name: "index_presentations_on_member_id"
    t.index ["title"], name: "index_presentations_on_title"
  end

  create_table "presentationships", force: :cascade do |t|
    t.integer "member_id"
    t.integer "event_id"
    t.integer "presentation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_presentationships_on_event_id"
    t.index ["member_id", "event_id", "presentation_id"], name: "presentationship_index", unique: true
    t.index ["member_id"], name: "index_presentationships_on_member_id"
    t.index ["presentation_id"], name: "index_presentationships_on_presentation_id"
  end

  create_table "registers", force: :cascade do |t|
    t.integer "event_id"
    t.integer "account_id"
    t.float "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_registers_on_account_id"
    t.index ["amount"], name: "index_registers_on_amount"
    t.index ["event_id"], name: "index_registers_on_event_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "member_id"
    t.integer "event_id"
    t.integer "presentation_role", default: 0
    t.integer "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "guest_flg"
    t.string "note", limit: 255
    t.index ["event_id"], name: "index_relationships_on_event_id"
    t.index ["guest_flg"], name: "index_relationships_on_guest_flg"
    t.index ["member_id", "event_id"], name: "index_relationships_on_member_id_and_event_id", unique: true
    t.index ["member_id"], name: "index_relationships_on_member_id"
    t.index ["note"], name: "index_relationships_on_note"
    t.index ["presentation_role"], name: "index_relationships_on_presentation_role"
    t.index ["status"], name: "index_relationships_on_status"
  end

  create_table "schedule_logs", force: :cascade do |t|
    t.integer "event_id"
    t.integer "member_id"
    t.integer "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_id"], name: "index_schedule_logs_on_event_id"
    t.index ["member_id"], name: "index_schedule_logs_on_member_id"
    t.index ["status"], name: "index_schedule_logs_on_status"
  end

  create_table "staffs", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.string "password", limit: 255
    t.string "password_digest", limit: 255
    t.string "remember_token", limit: 255
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.string "image_url", limit: 255
    t.string "access_token", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "admin"
    t.integer "member_id"
    t.boolean "active_flg"
    t.string "description"
    t.index ["access_token"], name: "index_staffs_on_access_token"
    t.index ["email"], name: "index_staffs_on_email", unique: true
    t.index ["provider"], name: "index_staffs_on_provider"
    t.index ["remember_token"], name: "index_staffs_on_remember_token"
    t.index ["uid"], name: "index_staffs_on_uid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
