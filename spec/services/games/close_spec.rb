# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::Close do
  subject { described_class.call(**attributes) }

  let(:game) { create(:game, :in_progress) }
  let(:result) { 'owner' }

  let(:attributes) { { game: game, result: result } }
  let(:value) { subject.value! }

  describe '#call' do
    context 'when attributes are valid' do
      before do
        allow(UpdateElo).to receive(:call).and_return(Dry::Monads::Success())
      end

      context 'when owner wins' do
        let(:result) { 'owner' }

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a game' do
          expect(value).to be_a(Game)
        end

        it 'returns a game with status complete' do
          expect(value).to be_complete_status
        end

        it 'returns a game with owner as winner' do
          expect(value.winner).to eq(game.owner)
        end

        it 'calls UpdateElo' do
          subject
          expect(UpdateElo).to have_received(:call).with(owner: game.owner, opponent: game.opponent, result: result)
        end
      end

      context 'when opponent wins' do
        let(:result) { 'opponent' }

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a game' do
          expect(value).to be_a(Game)
        end

        it 'returns a game with status complete' do
          expect(value).to be_complete_status
        end

        it 'returns a game with opponent as winner' do
          expect(value.winner).to eq(game.opponent)
        end

        it 'calls UpdateElo' do
          subject
          expect(UpdateElo).to have_received(:call).with(owner: game.owner, opponent: game.opponent, result: result)
        end
      end

      context 'when game is a draw' do
        let(:result) { 'draw' }

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a game' do
          expect(value).to be_a(Game)
        end

        it 'returns a game with status complete' do
          expect(value).to be_complete_status
        end

        it 'returns a game with no winner' do
          expect(value.winner).to be_nil
        end

        it 'calls UpdateElo' do
          subject
          expect(UpdateElo).to have_received(:call).with(owner: game.owner, opponent: game.opponent, result: result)
        end
      end
    end

    context 'when inputs have issue' do
      context 'when attributes are not passed' do
        let(:attributes) { {} }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Close: option 'game'/)
        end
      end

      context 'when game is not passed' do
        let(:attributes) { { result: result } }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Close: option 'game'/)
        end
      end

      context 'when result is not passed' do
        let(:attributes) { { game: game } }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /Games::Close: option 'result'/)
        end
      end

      context 'when result is invalid' do
        let(:result) { 'invalid' }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Invalid result')
        end
      end

      context 'when game is pending' do
        let(:game) { create(:game, :pending) }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Game is not started')
        end
      end

      context 'when game is finished' do
        let(:game) { create(:game, :complete) }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Game is finished')
        end
      end

      context 'when UpdateElo fails' do
        before do
          update_elo = instance_double(UpdateElo)
          allow(UpdateElo).to receive(:new).and_return(update_elo)

          allow(update_elo).to receive(:call).and_return(Dry::Monads::Failure('Elo update failed'))
        end

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Elo update failed')
        end
      end
    end
  end
end
