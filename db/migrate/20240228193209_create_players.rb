# frozen_string_literal: true

class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :nickname, null: false, unique: true
      t.string :password
      t.integer :elo, default: 1500

      t.timestamps
    end

    add_index :players, :nickname, unique: true
  end
end
