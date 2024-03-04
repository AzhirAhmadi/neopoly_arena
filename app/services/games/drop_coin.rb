# frozen_string_literal: true

module Games
  class DropCoin < ApplicationService
    option :game, Types.Instance(Game)
    option :player, Types.Instance(Player)
    option :move, Types::String

    def call
      ActiveRecord::Base.transaction do
        move_service
        result = check_board_service

        close_game_service(result) unless result == 'in_progress'

        Success(game.reload)
      rescue StandardError => exception
        Failure(exception.message)
      end
    end

    private

    def move_service
      attributes = {
        game: game,
        player: player,
        move: move
      }

      Games::Move.call(**attributes) do |result|
        result.success { |g| g }
        result.failure { |error| raise ActiveRecord::Rollback, error }
      end
    end

    def check_board_service
      attributes = {
        game: game
      }

      Games::CheckBoard.call(**attributes) do |result|
        result.success { |r| r }
        result.failure { |error| raise ActiveRecord::Rollback, error }
      end
    end

    def close_game_service(game_result)
      attributes = {
        game: game,
        result: game_result
      }

      Games::Close.call(**attributes) do |result|
        result.success { |g| g }
        result.failure { |error| raise ActiveRecord::Rollback, error }
      end
    end
  end
end
