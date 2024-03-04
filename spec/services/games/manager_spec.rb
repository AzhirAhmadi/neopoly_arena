# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Manager do
  subject { described_class.call(**attributes) }

  let(:owner) { create(:player, elo: 1000) }
  let(:opponent) { create(:player, elo: 1000) }
  let(:turn) { 'owner' }

  let(:game) { create(:game, :in_progress, owner: owner, opponent: opponent, turn: turn) }
  let(:player) { owner }
  let(:move) { '1-1' }

  let(:attributes) { { game: game, player: player, move: move } }

  describe '#call' do
    context 'when attributes are valid' do
      before do
        allow(Games::Move).to receive(:call).and_call_original
        allow(Games::CheckBoard).to receive(:call).and_call_original
        allow(Games::Close).to receive(:call).and_call_original
        allow(UpdateElo).to receive(:call).and_call_original
      end

      context 'when it is the owner turn' do
        let(:player) { owner }
        let(:turn) { 'owner' }

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a game' do
          expect(subject.value!).to be_a(Game)
        end

        it 'calls Games::Move' do
          subject

          expect(Games::Move).to have_received(:call).with(game: game, player: owner, move: move)
        end

        it 'calls Games::CheckBoard' do
          subject

          expect(Games::CheckBoard).to have_received(:call).with(game: game)
        end

        it 'does not call Games::Close' do
          subject

          expect(Games::Close).not_to have_received(:call)
        end
      end

      context 'when it is the opponent turn' do
        let(:player) { opponent }
        let(:turn) { 'opponent' }

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a game' do
          expect(subject.value!).to be_a(Game)
        end

        it 'calls Games::Move' do
          subject

          expect(Games::Move).to have_received(:call).with(game: game, player: opponent, move: move)
        end

        it 'calls Games::CheckBoard' do
          subject

          expect(Games::CheckBoard).to have_received(:call).with(game: game)
        end

        it 'does not call Games::Close' do
          subject

          expect(Games::Close).not_to have_received(:call)
        end
      end

      context 'when the game will be closed after the move' do
        before do
          # This is a draw game after the move
          board = %w(
            #XOXOXOX
            XOXOXOXO
            OXOXOXOX
            OXOXOXOX
            XOXOXOXO
            OXOXOXOX
            OXOXOXOX
            XOXOXOXO
          ).join

          game.update!(board: board)
        end

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a game' do
          expect(subject.value!).to be_a(Game)
        end

        it 'calls Games::Move' do
          subject

          expect(Games::Move).to have_received(:call).with(game: game, player: owner, move: move)
        end

        it 'calls Games::CheckBoard' do
          subject

          expect(Games::CheckBoard).to have_received(:call).with(game: game)
        end

        it 'calls Games::Close' do
          subject

          expect(Games::Close).to have_received(:call).with(game: game, result: 'draw')
        end

        it 'calls UpdateElo' do
          subject

          expect(UpdateElo).to have_received(:call).with(owner: owner, opponent: opponent, result: 'draw')
        end
      end
    end

    context 'when attributes have issue' do
      context 'when attributes are not passed' do
        let(:attributes) { {} }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Manager: option 'game'/)
        end
      end

      context 'when game is not passed' do
        let(:attributes) { super().except(:game) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Manager: option 'game'/)
        end
      end

      context 'when player is not passed' do
        let(:attributes) { super().except(:player) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Manager: option 'player'/)
        end
      end

      context 'when move is not passed' do
        let(:attributes) { super().except(:move) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Manager: option 'move'/)
        end
      end

      context 'when Game::Move fails' do
        before do
          move = instance_double(Games::Move)
          allow(Games::Move).to receive(:new).and_return(move)

          allow(move).to receive(:call).and_return(Dry::Monads::Failure('Invalid move'))
        end

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Invalid move')
        end

        it 'does not update the turn' do
          expect(game.reload.turn).to eq('owner')
        end

        it 'does not update the board' do
          expect(game.reload.board).to eq(Game::DEFAULT_BOARD)
        end

        it 'does not update the status' do
          expect(game.reload.status).to eq('in_progress')
        end
      end

      context 'when Game::CheckBoard fails' do
        before do
          check_board = instance_double(Games::CheckBoard)
          allow(Games::CheckBoard).to receive(:new).and_return(check_board)

          allow(check_board).to receive(:call).and_return(Dry::Monads::Failure('Invalid board'))
        end

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Invalid board')
        end

        it 'does not update the turn' do
          expect(game.reload.turn).to eq('owner')
        end

        it 'does not update the board' do
          expect(game.reload.board).to eq(Game::DEFAULT_BOARD)
        end

        it 'does not update the status' do
          expect(game.reload.status).to eq('in_progress')
        end
      end

      context 'when Game::Close fails' do
        before do
          close = instance_double(Games::Close)
          allow(Games::Close).to receive(:new).and_return(close)

          allow(close).to receive(:call).and_return(Dry::Monads::Failure('Invalid result'))

          # This is a draw game after the move
          board = %w(
            #XOXOXOX
            XOXOXOXO
            OXOXOXOX
            OXOXOXOX
            XOXOXOXO
            OXOXOXOX
            OXOXOXOX
            XOXOXOXO
          ).join

          game.update!(board: board)
        end

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Invalid result')
        end

        it 'does not update the status' do
          expect(game.reload.status).to eq('in_progress')
        end

        it 'does not update the winner' do
          expect(game.reload.winner).to be_nil
        end

        it 'does not update the elo' do
          expect(game.reload.owner.elo).to eq(1000)
        end
      end
    end
  end
end
