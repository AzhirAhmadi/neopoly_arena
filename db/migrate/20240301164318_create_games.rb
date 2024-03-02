# frozen_string_literal: true

class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.references :owner, null: false, foreign_key: { to_table: :players }
      t.references :opponent, foreign_key: { to_table: :players }
      t.references :winner, foreign_key: { to_table: :players }

      t.string :status
      t.string :turn
      t.string :board

      t.timestamps
    end
  end
end
