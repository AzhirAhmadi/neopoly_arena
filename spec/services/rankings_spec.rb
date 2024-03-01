# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rankings do
  describe '.call' do
    subject { described_class.call(**attributes) }

    let!(:players) do
      create_list(:player, 10, :with_random_elo)
        .map { |player| { id: player.id, elo: player.elo } }
        .sort_by { |player| player[:elo] }.reverse
    end

    context 'for checking the players' do
      let(:value) { subject.value![:items].map { |item| { id: item[:player][:id], elo: item[:player][:elo] } } }

      context 'when no attributes are given' do
        let(:attributes) { {} }

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns the top 100 players' do
          expect(value).to eq(players.first(100))
        end
      end

      context 'when the limit is 3' do
        let(:attributes) { { limit: 3 } }

        context 'when the offset is 0' do
          let(:attributes) { super().merge(offset: 0) }

          it 'returns a success' do
            expect(subject).to be_success
          end

          it 'returns the top 3 players' do
            expect(value).to eq(players.first(3))
          end
        end

        context 'when the offset is 3' do
          let(:attributes) { super().merge(offset: 3) }

          it 'returns a success' do
            expect(subject).to be_success
          end

          it 'returns the second top 3 players' do
            expect(value).to eq(players.values_at(3..5))
          end
        end
      end
    end

    context 'for checking the index and rank' do
      let(:value) { subject.value![:items].map { |item| { index: item[:index], rank: item[:rank] } } }

      context 'when no attributes are given' do
        let(:attributes) { {} }

        it 'returns the top 100 players' do
          expected_value = (0...10).map { |index| { index: index, rank: index + 1 } }

          expect(value).to eq(expected_value)
        end
      end

      context 'when the limit is 3' do
        let(:attributes) { { limit: 3 } }

        context 'when the offset is 0' do
          let(:attributes) { super().merge(offset: 0) }

          it 'returns the top 3 players' do
            expected_value = [
              { index: 0, rank: 1 },
              { index: 1, rank: 2 },
              { index: 2, rank: 3 }
            ]

            expect(value).to eq(expected_value)
          end
        end

        context 'when the offset is 3' do
          let(:attributes) { super().merge(offset: 3) }

          it 'returns the second top 3 players' do
            expected_value = [
              { index: 0, rank: 4 },
              { index: 1, rank: 5 },
              { index: 2, rank: 6 }
            ]

            expect(value).to eq(expected_value)
          end
        end
      end
    end
  end
end
