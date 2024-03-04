# frozen_string_literal: true

class GameSerializer < ApplicationSerializer
  attributes :id, :status, :turn, :board, :pretty_board, :id_board

  belongs_to :owner, serializer: PlayerSerializer
  belongs_to :opponent, serializer: PlayerSerializer
  belongs_to :winner, serializer: PlayerSerializer

  def pretty_board
    object.board.scan(/.{#{Game::BOARD_SIZE}}/o).join("\n")
  end

  def id_board
    object.board.scan(/.{#{Game::BOARD_SIZE}}/o).map(&:chars).map do |row|
      row.map do |cell|
        case cell
        when Game::BOARD_MARK
          nil
        when Game::OWNER_MARK
          object.owner_id
        when Game::OPPONENT_MARK
          object.opponent_id
        end
      end
    end
  end
end
