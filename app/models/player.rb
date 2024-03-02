# frozen_string_literal: true

class Player < ApplicationRecord
  validates :nickname, presence: true, uniqueness: true
  validates :password, presence: true

  has_many :owned_games, class_name: 'Game', foreign_key: :owner_id, inverse_of: :owner
  has_many :opponent_games, class_name: 'Game', foreign_key: :opponent_id, inverse_of: :opponent

  def games
    Game.where('owner_id = :id OR opponent_id = :id', id: id)
  end

  def pending_games
    games.where(status: :pending)
  end

  def in_progress_games
    games.where(status: :in_progress)
  end

  def complete_games
    games.where(status: :complete)
  end

  def lost_games
    complete_games.where('winner_id != :id AND winner_id IS NOT NULL', id: id)
  end

  def won_games
    complete_games.where(winner_id: id)
  end

  def drawn_games
    complete_games.where(winner_id: nil)
  end
end
