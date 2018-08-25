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

ActiveRecord::Schema.define(version: 2018_08_25_161304) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversations", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "textbook_id"
    t.index ["textbook_id"], name: "index_conversations_on_textbook_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "textbook_id"
    t.string "file_extension"
    t.string "url_created_at"
    t.string "file_name"
    t.index ["textbook_id"], name: "index_images_on_textbook_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.bigint "conversation_id"
    t.bigint "user_id"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notify_items", force: :cascade do |t|
    t.string "category"
    t.string "input"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_notify_items_on_user_id"
  end

  create_table "textbooks", force: :cascade do |t|
    t.string "textbook_title"
    t.string "textbook_author"
    t.string "textbook_edition"
    t.string "textbook_condition"
    t.string "textbook_type"
    t.string "textbook_coursecode"
    t.string "textbook_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_textbooks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "firebase_token"
  end

  add_foreign_key "conversations", "textbooks"
  add_foreign_key "images", "textbooks"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "notify_items", "users"
  add_foreign_key "textbooks", "users"
end
