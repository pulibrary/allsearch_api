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

ActiveRecord::Schema[7.1].define(version: 2024_07_17_173433) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "banners", force: :cascade do |t|
    t.text "text", default: ""
    t.boolean "display_banner", default: false
    t.integer "alert_status", default: 1
    t.boolean "dismissible", default: true
    t.boolean "autoclear", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "best_bet_records", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "url"
    t.string "search_terms", array: true
    t.date "last_update"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
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
    t.string "team"
    t.string "division"
    t.string "department"
    t.string "unit"
    t.string "office"
    t.string "building"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "areas_of_study"
    t.string "other_entities"
    t.string "my_scheduler_link"
    t.virtual "searchable", type: :tsvector, as: "to_tsvector('english'::regconfig, (((((((((((((((((((((((((((COALESCE(title, ''::character varying))::text || ' '::text) || (COALESCE(first_name, ''::character varying))::text) || ' '::text) || (COALESCE(middle_name, ''::character varying))::text) || ' '::text) || (COALESCE(last_name, ''::character varying))::text) || ' '::text) || (COALESCE(title, ''::character varying))::text) || ' '::text) || (COALESCE(email, ''::character varying))::text) || ' '::text) || (COALESCE(department, ''::character varying))::text) || ' '::text) || (COALESCE(office, ''::character varying))::text) || ' '::text) || (COALESCE(building, ''::character varying))::text) || ' '::text) || (COALESCE(team, ''::character varying))::text) || ' '::text) || (COALESCE(division, ''::character varying))::text) || ' '::text) || (COALESCE(unit, ''::character varying))::text) || ' '::text) || (COALESCE(areas_of_study, ''::character varying))::text) || ' '::text) || (COALESCE(other_entities, ''::character varying))::text))", stored: true
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
