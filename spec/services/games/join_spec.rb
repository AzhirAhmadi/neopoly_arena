# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Join do
  subject { described_class.call(**attributes) }

  let(:owner) { create(:player) }
  let(:opponent) { create(:player) }
  let(:game) { create(:game, :pending, owner: owner) }

  let(:value) { subject.value! }

  describe '#call' do
    context 'when correct attributes are passed' do
      let(:attributes) do
        {
          game: game,
          opponent: opponent
        }
      end

      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'returns a game' do
        expect(value).to be_a(Game)
      end

      it 'returns a game with owner player as owner' do
        expect(value.owner).to eq(owner)
      end

      it 'returns a game with opponent player as opponent' do
        expect(value.opponent).to eq(opponent)
      end

      it 'returns a game with status in_progress' do
        expect(value).to be_in_progress_status
      end

      it 'returns a game with a turn of owner' do
        expect(value).to be_owner_turn
      end

      it 'returns a game with a default board' do
        expect(value.board).to eq(Game::DEFAULT_BOARD)
      end
    end

    context 'when opponent is not passed' do
      let(:attributes) { { game: game } }

      it 'raises a KeyError' do
        expect { subject }.to raise_error(KeyError, /Games::Join: option 'opponent'/)
      end
    end

    context 'when game is not passed' do
      let(:attributes) { { opponent: opponent } }

      it 'raises a KeyError' do
        expect { subject }.to raise_error(KeyError, /Games::Join: option 'game'/)
      end
    end

    context 'when game is not pending' do
      let(:game) { create(:game, :in_progress) }
      let(:attributes) do
        {
          game: game,
          opponent: opponent
        }
      end

      it 'returns a failure' do
        expect(subject).to be_failure
      end

      it 'returns a failure message `Game is not pending`' do
        expect(subject.failure).to eq('Game is not pending')
      end
    end

    context 'when pass the same player as owner and opponent' do
      let(:attributes) do
        {
          game: game,
          opponent: owner
        }
      end

      it 'returns a failure' do
        expect(subject).to be_failure
      end

      it 'returns a failure message `Player cannot join their own game`' do
        expect(subject.failure).to eq('Player cannot join their own game')
      end
    end
  end
end
