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

ActiveRecord::Schema.define(version: 20161029201010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "choices", force: :cascade do |t|
    t.text     "text"
    t.integer  "question_id"
    t.integer  "ordinality"
    t.integer  "voice_count"
    t.boolean  "is_pass"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["question_id"], name: "index_choices_on_question_id", using: :btree
  end

  create_table "questions", force: :cascade do |t|
    t.text     "text"
    t.integer  "user_auth_id"
    t.boolean  "anonymous"
    t.integer  "cents"
    t.boolean  "randomize"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_auth_id"], name: "index_questions_on_user_auth_id", using: :btree
  end

  create_table "thoughts", force: :cascade do |t|
    t.text     "text"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_auth_id"
    t.index ["user_auth_id"], name: "index_thoughts_on_user_auth_id", using: :btree
  end

  create_table "user_auths", force: :cascade do |t|
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.string   "name"
    t.string   "location"
    t.string   "image_url"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "star_count"
    t.index ["provider", "uid"], name: "index_user_auths_on_provider_and_uid", unique: true, using: :btree
    t.index ["provider"], name: "index_user_auths_on_provider", using: :btree
    t.index ["uid"], name: "index_user_auths_on_uid", using: :btree
  end

  create_table "voices", force: :cascade do |t|
    t.integer  "user_auth_id"
    t.integer  "question_id"
    t.integer  "choice_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "is_pass"
    t.index ["choice_id"], name: "index_voices_on_choice_id", using: :btree
    t.index ["question_id"], name: "index_voices_on_question_id", using: :btree
    t.index ["user_auth_id"], name: "index_voices_on_user_auth_id", using: :btree
  end

  add_foreign_key "choices", "questions"
  add_foreign_key "questions", "user_auths"
  add_foreign_key "thoughts", "user_auths"
  add_foreign_key "voices", "choices"
  add_foreign_key "voices", "questions"
  add_foreign_key "voices", "user_auths"
end
