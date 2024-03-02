# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Player, type: :model do
  subject { described_class.new(nickname: 'Any', password: 'Any') }

  describe 'associations' do
    it { is_expected.to have_many(:owned_games).class_name('Game').with_foreign_key(:owner_id).inverse_of(:owner) }
    it { is_expected.to have_many(:opponent_games).class_name('Game').with_foreign_key(:opponent_id).inverse_of(:opponent) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:nickname) }
    it { is_expected.to validate_uniqueness_of(:nickname).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe 'scopes' do
    let(:player) { create(:player) }

    let(:lost_games) do
      [
        create(:game, :owner_lost, owner: player),
        create(:game, :opponent_lost, opponent: player)
      ]
    end

    let(:won_games) do
      [
        create(:game, :owner_won, owner: player),
        create(:game, :opponent_won, opponent: player)
      ]
    end

    let(:drawn_games) do
      [
        create(:game, :drawn, owner: player),
        create(:game, :drawn, opponent: player)
      ]
    end

    let(:complete_games) do
      lost_games + won_games + drawn_games
    end

    let(:in_progress_games) do
      [
        create(:game, :in_progress, owner: player),
        create(:game, :in_progress, opponent: player)
      ]
    end

    let(:pending_games) do
      [
        create(:game, :pending, owner: player),
        create(:game, :pending, opponent: player)
      ]
    end

    let!(:games) do
      complete_games + in_progress_games + pending_games
    end

    before do
      # Adding some games none related to the player

      create(:game, status: :complete)
      create(:game, status: :in_progress)
      create(:game, status: :pending)
      create(:game, status: :complete, winner: create(:player))
    end

    describe '.games' do
      it 'returns all games' do
        expect(player.games).to match_array(games)
      end
    end

    describe '.pending_games' do
      it 'returns pending games' do
        expect(player.pending_games).to match_array(pending_games)
      end
    end

    describe '.in_progress_games' do
      it 'returns in progress games' do
        expect(player.in_progress_games).to match_array(in_progress_games)
      end
    end

    describe '.complete_games' do
      it 'returns complete games' do
        expect(player.complete_games).to match_array(complete_games)
      end
    end

    describe '.lost_games' do
      it 'returns lost games' do
        expect(player.lost_games).to match_array(lost_games)
      end
    end

    describe '.won_games' do
      it 'returns won games' do
        expect(player.won_games).to match_array(won_games)
      end
    end

    describe '.drawn_games' do
      it 'returns drawn games' do
        expect(player.drawn_games).to match_array(drawn_games)
      end
    end
  end
end
