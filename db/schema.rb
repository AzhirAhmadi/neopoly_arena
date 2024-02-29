# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_240_228_215_118) do
  create_table 'players', force: :cascade do |t|
    t.string 'nickname', null: false
    t.string 'password'
    t.integer 'elo', default: 1500
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'session'
    t.datetime 'session_expires_at'
    t.index ['nickname'], name: 'index_players_on_nickname', unique: true
    t.index ['session'], name: 'index_players_on_session', unique: true
  end
end
