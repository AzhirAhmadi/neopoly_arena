# frozen_string_literal: true

module Games
  class Close < ApplicationService
    option :game, Types.Instance(Game)
    option :result, Types::String

    def call
      yield valid_game?
      yield valid_result?

      ActiveRecord::Base.transaction do
        game.update!(status: 'complete', winner: winner)

        update_elo

        Success(game)
      rescue StandardError => exception
        Failure(exception.message)
      end
    end

    private

    def valid_game?
      return Failure('Game is not started') if game.pending_status?
      return Failure('Game is finished') if game.complete_status?

      Success()
    end

    def valid_result?
      return Failure('Invalid result') unless %w(owner opponent draw).include?(result)

      Success()
    end

    def winner
      return game.owner if result == 'owner'
      return game.opponent if result == 'opponent'

      nil
    end

    def update_elo
      attributes = {
        owner: game.owner,
        opponent: game.opponent,
        result: result
      }

      UpdateElo.call(**attributes) do |result|
        result.success { nil }
        result.failure { |error| raise ActiveRecord::Rollback, error }
      end
    end
  end
end
