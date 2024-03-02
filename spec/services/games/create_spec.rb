# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Create do
  subject { described_class.call(**attributes) }

  let(:attributes) { { player: player } }
  let(:player) { create(:player) }
  let(:value) { subject.value! }

  describe '#call' do
    context 'when player is passed' do
      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'returns a game' do
        expect(value).to be_a(Game)
      end

      it 'returns a game with player as owner' do
        expect(value.owner).to eq(player)
      end

      it 'returns a game with status pending' do
        expect(value).to be_pending_status
      end

      it 'returns a game with a turn of owner' do
        expect(value).to be_owner_turn
      end

      it 'returns a game with a default board' do
        expect(value.board).to eq(Game::DEFAULT_BOARD)
      end
    end

    context 'when player is not passed' do
      let(:attributes) { {} }

      it 'raises a KeyError' do
        expect { subject }.to raise_error(KeyError, /Games::Create: option 'player'/)
      end
    end
  end
end
