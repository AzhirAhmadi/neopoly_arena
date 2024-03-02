# frozen_string_literal: true

class AddSessionToPlayer < ActiveRecord::Migration[6.1]
  def change
    change_table :players, bulk: true do |t|
      t.string :session
      t.datetime :session_expires_at
    end

    add_index :players, :session, unique: true
  end
end
