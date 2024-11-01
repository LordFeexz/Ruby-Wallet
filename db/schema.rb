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

ActiveRecord::Schema[7.2].define(version: 2024_11_01_022947) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "team_members", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "user_id"], name: "index_team_members_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id"
    t.index ["name"], name: "unique_name", unique: true
    t.index ["owner_id"], name: "index_teams_on_owner_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.string "transaction_type", null: false
    t.text "description"
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "unique_username", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.integer "reference_id", null: false
    t.string "reference_type", null: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "team_members", "teams", on_update: :cascade, on_delete: :cascade
  add_foreign_key "team_members", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "teams", "users", column: "owner_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transactions", "users", on_update: :cascade, on_delete: :nullify
end
