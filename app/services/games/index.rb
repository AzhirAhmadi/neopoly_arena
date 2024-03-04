# frozen_string_literal: true

module Games
  class Index < ApplicationService
    option :limit, type: Types.Instance(Integer), default: proc { 100 }
    option :offset, type: Types.Instance(Integer), default: proc { 0 }

    def call
      Success({
        total: Game.count,
        items: items
      })
    end

    private

    def items
      games.map do |game|
        {
          id: game.id,
          status: game.status,
          winner: player_hash(game.winner),
          players: [
            player_hash(game.owner),
            player_hash(game.opponent)
          ].compact
        }.compact
      end
    end

    def games
      Game.limit(limit).offset(offset)
    end

    def player_hash(player)
      return nil if player.nil?

      {
        id: player.id,
        nickname: player.nickname,
        elo: player.elo
      }
    end
  end
end
