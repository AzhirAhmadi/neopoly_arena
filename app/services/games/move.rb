# frozen_string_literal: true

module Games
  class Move < ApplicationService
    option :game, Types.Instance(Game)
    option :player, Types.Instance(Player)
    option :move, Types::String

    def call
      yield valid_game?
      yield valid_move?

      if game.update!(board: new_board, turn: new_turn)
        Success(game)
      else
        Failure('Could not update game')
      end
    end

    private

    def valid_game?
      return Failure('Your are not in this game') if game.owner != player && game.opponent != player
      return Failure('Game is not started') if game.pending_status?
      return Failure('Game is finished') if game.complete_status?

      Success()
    end

    def valid_move?
      return Failure('Not your turn') unless player_turn?
      return Failure('Invalid move format') unless move.match?(/\A\d+-\d+\z/)
      return Failure('Invalid move range') unless valid_move_range?
      return Failure('Invalid move position') unless game.board[index] == '#'

      Success()
    end

    def player_turn?
      return true if game.owner_turn? && game.owner == player
      return true if game.opponent_turn? && game.opponent == player

      false
    end

    def valid_move_range?
      move.split('-').all? { |n| n.to_i.between?(1, Game::BOARD_SIZE) }
    end

    def index
      @_index ||= move.split('-').map(&:to_i).then { |x, y| (x - 1) + ((y - 1) * Game::BOARD_SIZE) }
    end

    def new_turn
      game.owner_turn? ? 'opponent' : 'owner'
    end

    def new_board
      game.board.tap { |b| b[index] = player_chip }
    end

    def player_chip
      game.owner == player ? 'X' : 'O'
    end
  end
end
