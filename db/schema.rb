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

ActiveRecord::Schema[7.0].define(version: 2023_09_19_194551) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "best_bet_documents", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "url"
    t.string "search_terms", array: true
    t.date "last_update"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_tokens", force: :cascade do |t|
    t.string "service", null: false
    t.string "endpoint", null: false
    t.string "token"
    t.datetime "expiration_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_oauth_tokens_on_endpoint", unique: true
    t.index ["service"], name: "index_oauth_tokens_on_service", unique: true
  end

end
