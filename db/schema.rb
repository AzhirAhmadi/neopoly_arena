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

ActiveRecord::Schema.define(version: 2024_03_01_164318) do

  create_table "games", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.bigint "opponent_id"
    t.bigint "winner_id"
    t.string "status"
    t.string "turn"
    t.string "board"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["opponent_id"], name: "index_games_on_opponent_id"
    t.index ["owner_id"], name: "index_games_on_owner_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "players", charset: "utf8mb4", force: :cascade do |t|
    t.string "nickname", null: false
    t.string "password"
    t.integer "elo", default: 1500
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "session"
    t.datetime "session_expires_at"
    t.index ["nickname"], name: "index_players_on_nickname", unique: true
    t.index ["session"], name: "index_players_on_session", unique: true
  end

  add_foreign_key "games", "players", column: "opponent_id"
  add_foreign_key "games", "players", column: "owner_id"
  add_foreign_key "games", "players", column: "winner_id"
end
