# frozen_string_literal: true

class AddSessionToPlayer < ActiveRecord::Migration[6.1]
  def change
    add_column :players, :session, :string
    add_column :players, :session_expires_at, :datetime
    add_index :players, :session, unique: true
  end
end
