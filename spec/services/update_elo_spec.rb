# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateElo do
  describe '#call' do
    subject { described_class.call(**attributes) }

    let(:owner) { create(:player, elo: 1000) }
    let(:opponent) { create(:player, elo: 1000) }
    let(:result) { 'owner' }

    let(:attributes) { { owner: owner, opponent: opponent, result: result } }

    context 'when the result is a owner win' do
      let(:result) { 'owner' }

      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'updates the owner elo' do
        expect { subject }.to change { owner.reload.elo }.from(1000).to(1016)
      end

      it 'updates the opponent elo' do
        expect { subject }.to change { opponent.reload.elo }.from(1000).to(984)
      end
    end

    context 'when the result is a opponent win' do
      let(:result) { 'opponent' }

      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'updates the owner elo' do
        expect { subject }.to change { owner.reload.elo }.from(1000).to(984)
      end

      it 'updates the opponent elo' do
        expect { subject }.to change { opponent.reload.elo }.from(1000).to(1016)
      end
    end

    context 'when the result is a draw' do
      let(:result) { 'draw' }

      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'updates the owner elo' do
        expect { subject }.not_to change { owner.reload.elo }
      end

      it 'updates the opponent elo' do
        expect { subject }.not_to change { opponent.reload.elo }
      end
    end

    context 'when inputs have issue' do
      context 'when attributes are not passed' do
        let(:attributes) { {} }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /UpdateElo: option 'owner'/)
        end
      end

      context 'when owner is not passed' do
        let(:attributes) { super().except(:owner) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /UpdateElo: option 'owner'/)
        end
      end

      context 'when opponent is not passed' do
        let(:attributes) { super().except(:opponent) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /UpdateElo: option 'opponent'/)
        end
      end

      context 'when result is not passed' do
        let(:attributes) { super().except(:result) }

        it 'raises a KeyError' do
          expect { subject }.to raise_error(KeyError, /UpdateElo: option 'result'/)
        end
      end

      context 'when owner is the same as opponent' do
        let(:attributes) { { owner: owner, opponent: owner, result: 'owner' } }

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('Same players')
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

      context 'when update! raises an error' do
        before do
          allow(owner).to receive(:update!).and_raise('update! failed')
        end

        it 'returns a failure' do
          expect(subject).to be_failure
        end

        it 'returns a message' do
          expect(subject.failure).to eq('update! failed')
        end
      end
    end
  end
end
