# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Games::CheckBoard do
  subject { described_class.call(**attributes) }

  let(:game) { create(:game, :in_progress, board: board) }
  let(:board) { Game::DEFAULT_BOARD }

  describe '#call' do
    context 'when owner wins' do
      context 'for a horizontal match' do
        let(:attributes) { { game: game } }
        let(:board) do
          %w(
            ########
            ########
            ########
            ########
            ########
            ########
            ########
            XXXX####
          ).join
        end

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a winner' do
          expect(subject.value!).to eq('owner')
        end
      end

      context 'for a vertical match' do
        let(:attributes) { { game: game } }
        let(:board) do
          %w(
            ########
            ########
            ########
            ########
            #X######
            #X######
            #X######
            #X######
          ).join
        end

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a winner' do
          expect(subject.value!).to eq('owner')
        end
      end

      context 'for a diagonal match' do
        context 'for a left diagonal match' do
          let(:attributes) { { game: game } }
          let(:board) do
            %w(
              ########
              ########
              ########
              ########
              ###X####
              ##X#####
              #X######
              X#######
            ).join
          end

          it 'returns a success' do
            expect(subject).to be_success
          end

          it 'returns a winner' do
            expect(subject.value!).to eq('owner')
          end
        end

        context 'for a right diagonal match' do
          let(:attributes) { { game: game } }
          let(:board) do
            %w(
              ########
              ########
              ########
              ########
              #X######
              ##X#####
              ###X####
              ####X###
            ).join
          end

          it 'returns a success' do
            expect(subject).to be_success
          end

          it 'returns a winner' do
            expect(subject.value!).to eq('owner')
          end
        end
      end
    end

    context 'when opponent wins' do
      context 'for a horizontal match' do
        let(:attributes) { { game: game } }
        let(:board) do
          %w(
            ########
            ########
            ########
            ########
            ########
            ########
            ########
            OOOO####
          ).join
        end

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a winner' do
          expect(subject.value!).to eq('opponent')
        end
      end

      context 'for a vertical match' do
        let(:attributes) { { game: game } }
        let(:board) do
          %w(
            ########
            ########
            ########
            ########
            #O######
            #O######
            #O######
            #O######
          ).join
        end

        it 'returns a success' do
          expect(subject).to be_success
        end

        it 'returns a winner' do
          expect(subject.value!).to eq('opponent')
        end
      end

      context 'for a diagonal match' do
        context 'for a left diagonal match' do
          let(:attributes) { { game: game } }
          let(:board) do
            %w(
              ########
              ########
              ########
              ########
              ###O####
              ##O#####
              #O######
              O#######
            ).join
          end

          it 'returns a success' do
            expect(subject).to be_success
          end

          it 'returns a winner' do
            expect(subject.value!).to eq('opponent')
          end
        end

        context 'for a right diagonal match' do
          let(:attributes) { { game: game } }
          let(:board) do
            %w(
              ########
              ########
              ########
              ########
              #O######
              ##O#####
              ###O####
              ####O###
            ).join
          end

          it 'returns a success' do
            expect(subject).to be_success
          end

          it 'returns a winner' do
            expect(subject.value!).to eq('opponent')
          end
        end
      end
    end

    context 'when the game is a draw' do
      let(:attributes) { { game: game } }
      let(:board) do
        %w(
          OXOXOXOX
          XOXOXOXO
          OXOXOXOX
          OXOXOXOX
          XOXOXOXO
          OXOXOXOX
          OXOXOXOX
          XOXOXOXO
        ).join
      end

      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'returns a draw' do
        expect(subject.value!).to eq('draw')
      end
    end

    context 'when game is not done' do
      let(:attributes) { { game: game } }
      let(:board) do
        %w(
          #XOXOXOX
          XOXOXOXO
          OXOXOXOX
          OXOXOXOX
          XOXOXOXO
          OXOXOXOX
          OXOXOXOX
          XOXOXOXO
        ).join
      end

      it 'returns a success' do
        expect(subject).to be_success
      end

      it 'returns a draw' do
        expect(subject.value!).to eq('in_progress')
      end
    end
  end
end
