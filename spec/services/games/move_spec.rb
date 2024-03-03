# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Move do
  subject { described_class.call(**attributes) }

  let(:player) { create(:player) }
  let(:game) { create(:game, :in_progress, owner: player) }
  let(:move) { '1-1' }

  let(:attributes) { { game: game, player: player, move: move } }

  let(:value) { subject.value! }

  describe '#call' do
    context 'when correct attributes are passed' do
      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'returns a game' do
        expect(value).to be_a(Game)
      end

      it 'returns a game with owner player as owner' do
        expect(value.owner).to eq(player)
      end

      it 'returns a game with status in_progress' do
        expect(value).to be_in_progress_status
      end

      context 'when it is owner turn' do
        let(:game) { create(:game, :in_progress, owner: player, turn: 'owner') }

        it 'returns a game with a turn of opponent' do
          expect(value).to be_opponent_turn
        end

        # rubocop:disable Style/RedundantInterpolation
        it 'returns a game with a updated board' do
          expect(value.board).to eq("#{Game::DEFAULT_BOARD}".tap { |x| x[0] = Game::OWNER_MARK })
        end
        # rubocop:enable Style/RedundantInterpolation
      end

      context 'when it is opponent turn' do
        let(:game) { create(:game, :in_progress, opponent: player, turn: 'opponent') }

        it 'returns a game with a turn of owner' do
          expect(value).to be_owner_turn
        end

        # rubocop:disable Style/RedundantInterpolation
        it 'returns a game with a updated board' do
          expect(value.board).to eq("#{Game::DEFAULT_BOARD}".tap { |x| x[0] = Game::OPPONENT_MARK })
        end
        # rubocop:enable Style/RedundantInterpolation
      end
    end

    context 'when inputs have issue' do
      context 'when attributes are not passed' do
        let(:attributes) { {} }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Move: option 'game'/)
        end
      end

      context 'when game is not passed' do
        let(:attributes) { super().except(:game) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Move: option 'game'/)
        end
      end

      context 'when player is not passed' do
        let(:attributes) { super().except(:player) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Move: option 'player'/)
        end
      end

      context 'when move is not passed' do
        let(:attributes) { super().except(:move) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Move: option 'move'/)
        end
      end

      context 'when player is not in the game' do
        let(:game) { create(:game, :in_progress) }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Your are not in this game')
        end
      end

      context 'when game is not started' do
        let(:game) { create(:game, :pending, owner: player) }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Game is not started')
        end
      end

      context 'when game is finished' do
        let(:game) { create(:game, :owner_won, owner: player) }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Game is finished')
        end
      end

      context 'when it is not player turn' do
        let(:game) { create(:game, :in_progress, owner: player, turn: 'opponent') }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Not your turn')
        end
      end

      context 'when move is not in the correct format' do
        let(:move) { '11' }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Invalid move format')
        end
      end

      context 'when move is not in the correct range' do
        let(:move) { '0-0' } # out of range move. range is 1-Game::BOARD_SIZE

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Invalid move range')
        end
      end

      context 'when move is not in the correct position' do
        let(:move) { '1-1' }
        let(:game) { create(:game, :in_progress, owner: player, board: 'X########') }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Invalid move position')
        end
      end

      context 'when update! fails' do
        before do
          allow(game).to receive(:update!).and_return(false)
        end

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Could not update game')
        end
      end
    end
  end
end
