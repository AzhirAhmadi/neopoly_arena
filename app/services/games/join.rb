# frozen_string_literal: true

module Games
  class Join < ApplicationService
    option :game, Types.Instance(Game)
    option :opponent, Types.Instance(Player)

    def call
      yield valid_game?

      if game.update!(opponent: opponent, status: 'in_progress')
        Success(game)
      else
        Failure(game.errors)
      end
    end

    private

    def valid_game?
      return Failure('Player cannot join their own game') if game.owner == opponent
      return Failure('Game is not pending') unless game.pending_status?

      Success()
    end
  end
end
