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

ActiveRecord::Schema[7.1].define(version: 2023_11_21_205208) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "best_bet_records", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "url"
    t.string "search_terms", array: true
    t.date "last_update"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "library_database_records", force: :cascade do |t|
    t.bigint "libguides_id", null: false
    t.string "name", null: false
    t.string "description"
    t.string "alt_names", array: true
    t.string "alt_names_concat"
    t.string "url"
    t.string "friendly_url"
    t.string "subjects", array: true
    t.string "subjects_concat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "searchable", type: :tsvector, as: "(((setweight(to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, (COALESCE(alt_names_concat, ''::character varying))::text), 'B'::\"char\")) || setweight(to_tsvector('english'::regconfig, (COALESCE(description, ''::character varying))::text), 'C'::\"char\")) || setweight(to_tsvector('english'::regconfig, (COALESCE(subjects_concat, ''::character varying))::text), 'D'::\"char\"))", stored: true
    t.index ["searchable"], name: "searchable_idx", using: :gin
  end

  create_table "library_staff_records", force: :cascade do |t|
    t.bigint "puid", null: false
    t.string "netid", null: false
    t.string "phone"
    t.string "name", null: false
    t.string "last_name"
    t.string "first_name"
    t.string "middle_name"
    t.string "title", null: false
    t.string "library_title", null: false
    t.string "email", null: false
    t.string "section"
    t.string "division"
    t.string "department", null: false
    t.string "unit"
    t.string "office"
    t.string "building"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "searchable", type: :tsvector, as: "to_tsvector('english'::regconfig, (((((((((((((((((((((((COALESCE(title, ''::character varying))::text || ' '::text) || (COALESCE(first_name, ''::character varying))::text) || ' '::text) || (COALESCE(middle_name, ''::character varying))::text) || ' '::text) || (COALESCE(last_name, ''::character varying))::text) || ' '::text) || (COALESCE(title, ''::character varying))::text) || ' '::text) || (COALESCE(email, ''::character varying))::text) || ' '::text) || (COALESCE(department, ''::character varying))::text) || ' '::text) || (COALESCE(office, ''::character varying))::text) || ' '::text) || (COALESCE(building, ''::character varying))::text) || ' '::text) || (COALESCE(section, ''::character varying))::text) || ' '::text) || (COALESCE(division, ''::character varying))::text) || ' '::text) || (COALESCE(unit, ''::character varying))::text))", stored: true
    t.index ["searchable"], name: "staff_search_idx", using: :gin
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
