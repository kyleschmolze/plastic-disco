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

ActiveRecord::Schema.define(version: 20160601043204) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.string   "kind"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "video_count"
    t.integer  "user_id"
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "events_videos", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "video_id"
  end

  add_index "events_videos", ["event_id"], name: "index_events_videos_on_event_id", using: :btree
  add_index "events_videos", ["video_id"], name: "index_events_videos_on_video_id", using: :btree

  create_table "highlights", force: :cascade do |t|
    t.integer  "video_id"
    t.integer  "offset"
    t.integer  "duration"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "highlights", ["video_id"], name: "index_highlights_on_video_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.json     "oauth_response"
  end

  create_table "videos", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "google_id"
    t.string   "title"
    t.string   "mime_type"
    t.string   "thumbnail"
    t.datetime "starts_at"
    t.integer  "duration"
    t.datetime "ends_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "height"
    t.integer  "width"
    t.string   "youtube_id"
    t.datetime "original_starts_at"
    t.datetime "original_ends_at"
    t.boolean  "aligned",            default: false
    t.boolean  "hidden",             default: false
  end

  add_index "videos", ["ends_at"], name: "index_videos_on_ends_at", using: :btree
  add_index "videos", ["google_id"], name: "index_videos_on_google_id", using: :btree
  add_index "videos", ["starts_at"], name: "index_videos_on_starts_at", using: :btree
  add_index "videos", ["user_id"], name: "index_videos_on_user_id", using: :btree

end
