# frozen_string_literal: true

class Rankings < ApplicationService
  option :limit, type: Types.Instance(Integer), default: proc { 100 }
  option :offset, type: Types.Instance(Integer), default: proc { 0 }

  def call
    Success({
      total: Player.count,
      items: items
    })
  end

  private

  def items
    result = []

    players.each_with_index do |player, index|
      result << {
        index: index,
        rank: index + 1 + offset,
        player: {
          id: player.id,
          nickname: player.nickname,
          elo: player.elo
        }
      }
    end

    result
  end

  def players
    Player.limit(limit).offset(offset).order(elo: :desc).order(created_at: :asc)
  end
end
