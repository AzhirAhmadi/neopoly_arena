# frozen_string_literal: true

module Games
  class Create < ApplicationService
    option :player, Types.Instance(Player)

    def call
      game = Game.new(owner: player, status: 'pending', turn: 'owner', board: Game::DEFAULT_BOARD)

      if game.save!
        Success(game)
      else
        Failure(game.errors)
      end
    end
  end
end
