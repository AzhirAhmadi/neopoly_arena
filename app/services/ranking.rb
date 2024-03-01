# frozen_string_literal: true

class Ranking < ApplicationService
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

    plyers.each_with_index do |player, index|
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

  def plyers
    Player.limit(limit).offset(offset).order(elo: :desc)
  end
end
