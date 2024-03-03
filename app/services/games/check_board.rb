# frozen_string_literal: true

module Games
  class CheckBoard < ApplicationService
    option :game, Types.Instance(Game)

    def call
      yield valid_game?

      Success(check_winner)
    end

    private

    def valid_game?
      return Failure('Game is not started') if game.pending_status?
      return Failure('Game is finished') if game.complete_status?

      Success()
    end

    def check_winner
      return 'owner' if winner?(Game::OWNER_MARK)
      return 'opponent' if winner?(Game::OPPONENT_MARK)
      return 'draw' if draw?

      'in_progress'
    end

    def winner?(mark)
      return true if horizontal_win?(mark)
      return true if vertical_win?(mark)
      return true if diagonal_win?(mark)

      false
    end

    def horizontal_win?(mark)
      board_rows.any? { |row| row.match?(/(?:#{Regexp.escape(mark)}{4})/) }
    end

    def vertical_win?(mark)
      board_columns.any? { |column| column.match?(/(?:#{Regexp.escape(mark)}{4})/) }
    end

    # TODO: Refactor this method to remove rubocop disable comments
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def diagonal_win?(mark)
      left_shifted_rows = []
      right_shifted_rows = []

      board_rows.each_with_index do |row, index|
        left_shifted_rows << (('0' * (Game::BOARD_SIZE - index)) + row + ('0' * index))
        right_shifted_rows << (('0' * index) + row + ('0' * (Game::BOARD_SIZE - index)))
      end

      return true if left_shifted_rows.map(&:chars).transpose.map(&:join).any? { |column| column.match?(/(?:#{Regexp.escape(mark)}{4})/) }
      return true if right_shifted_rows.map(&:chars).transpose.map(&:join).any? { |column| column.match?(/(?:#{Regexp.escape(mark)}{4})/) }

      false
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def board_rows
      game.board.scan(/.{#{Game::BOARD_SIZE}}/o)
    end

    def board_columns
      board_rows.map(&:chars).transpose.map(&:join)
    end

    def draw?
      game.board.exclude?(Game::BOARD_MARK)
    end
  end
end
