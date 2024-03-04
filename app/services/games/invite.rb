# frozen_string_literal: true

module Games
  class Invite < ApplicationService
    option :owner, Types.Instance(Player)
    option :opponent, Types.Instance(Player)

    def call
      ActiveRecord::Base.transaction do
        game = create_game

        updated_game = join_game(game)

        Success(updated_game)
      rescue StandardError => exception
        Failure(exception.message)
      end
    end

    private

    def create_game
      Games::Create.call(player: owner) do |result|
        result.success do |game|
          game
        end

        result.failure do |error|
          raise ActiveRecord::Rollback, error
        end
      end
    end

    def join_game(game)
      Games::Join.call(game: game, opponent: opponent) do |result|
        result.success do |record|
          record
        end

        result.failure do |error|
          raise ActiveRecord::Rollback, error
        end
      end
    end
  end
end
