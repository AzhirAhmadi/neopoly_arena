# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Invite do
  subject { described_class.call(**attributes) }

  let(:owner) { create(:player) }
  let(:opponent) { create(:player) }

  let(:attributes) do
    {
      owner: owner,
      opponent: opponent
    }
  end

  let(:stubbing_game) { create(:game, :pending, owner: owner, turn: 'owner', board: Game::DEFAULT_BOARD) }

  describe '#call' do
    context 'when correct attributes are passed' do
      before do
        create_game = instance_double(Games::Create)
        allow(Games::Create).to receive(:new).and_return(create_game)
        allow(create_game).to receive(:call).and_return(Dry::Monads::Success(stubbing_game))

        allow(Games::Create).to receive(:call).and_call_original
        allow(Games::Join).to receive(:call).and_call_original
      end

      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'returns a game' do
        expect(subject.value!).to be_a(Game)
      end

      it 'calls Games::Create' do
        subject

        expect(Games::Create).to have_received(:call).with(player: owner)
      end

      it 'calls Games::Join' do
        subject

        expect(Games::Join).to have_received(:call).with(game: stubbing_game, opponent: opponent)
      end
    end

    context 'when wrong attributes are passed' do
      context 'when attributes are missing' do
        let(:attributes) { {} }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Invite: option 'owner'/)
        end
      end

      context 'when owner is missing' do
        let(:attributes) { super().except(:owner) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Invite: option 'owner'/)
        end
      end

      context 'when opponent is missing' do
        let(:attributes) { super().except(:opponent) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Invite: option 'opponent'/)
        end
      end

      context 'when Game::Create fails' do
        before do
          create_game = instance_double(Games::Create)
          allow(Games::Create).to receive(:new).and_return(create_game)
          allow(create_game).to receive(:call).and_return(Dry::Monads::Failure('Game::Create failed'))
        end

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns an error' do
          expect(subject.failure).to eq('Game::Create failed')
        end
      end

      context 'when Game::Join fails' do
        before do
          join_game = instance_double(Games::Join)
          allow(Games::Join).to receive(:new).and_return(join_game)
          allow(join_game).to receive(:call).and_return(Dry::Monads::Failure('Game::Join failed'))

          allow(Games::Create).to receive(:call).and_call_original
        end

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns an error' do
          expect(subject.failure).to eq('Game::Join failed')
        end
      end
    end
  end
end
