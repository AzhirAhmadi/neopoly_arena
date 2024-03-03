# frozen_string_literal: true

class Game < ApplicationRecord
  OWNER_MARK = 'X'
  OPPONENT_MARK = 'O'

  BOARD_MARK = '#'
  BOARD_SIZE = 8
  DEFAULT_BOARD = (BOARD_MARK * BOARD_SIZE * BOARD_SIZE)

  belongs_to :owner, class_name: 'Player'
  belongs_to :opponent, class_name: 'Player', optional: true
  belongs_to :winner, class_name: 'Player', optional: true

  enum status: { pending: 'pending', in_progress: 'in_progress', complete: 'complete' }, _suffix: true
  enum turn: { owner: 'owner', opponent: 'opponent' }, _suffix: true

  validates :status, presence: true
  validates :turn, presence: true
  validates :board, presence: true
end
