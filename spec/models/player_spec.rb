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
        expect(player.lost_games.pluck(:id, :owner_id, :opponent_id,
:winner_id)).to match_array(lost_games.pluck(:id, :owner_id, :opponent_id, :winner_id))
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

  describe '#sing_in' do
    subject(:sing_in) { described_class.sing_in(nickname, password) }

    let(:player) { create(:player) }
    let(:nickname) { player.nickname }
    let(:password) { player.password }

    context 'when the nickname and password are correct' do
      before do |example|
        sing_in unless example.metadata[:skip_sign_in]

        player.reload
      end

      it 'returns a session', :skip_sign_in do
        expect(sing_in).to eq(player.reload.session)
      end

      it 'updates the session' do
        expect(player.session).to be_present
      end

      it 'updates session_expires_at' do
        expect(player.session_expires_at).to be_present
      end

      it 'returns a session that expires in 1 day' do
        expect(player.session_expires_at).to be_within(1.second).of(1.day.from_now)
      end

      context 'when player is already singed_in' do
        it 'returns a new session' do
          expect(described_class.sing_in(nickname, password)).not_to eq(player.session)
        end
      end
    end

    context 'when the nickname and password are incorrect' do
      context 'when the nickname is incorrect' do
        let(:nickname) { 'Incorrect' }

        it 'raises an error' do
          expect { sing_in }.to raise_error('Invalid nickname or password')
        end
      end

      context 'when the password is incorrect' do
        let(:password) { 'Incorrect' }

        it 'raises an error' do
          expect { sing_in }.to raise_error('Invalid nickname or password')
        end
      end
    end
  end
end
