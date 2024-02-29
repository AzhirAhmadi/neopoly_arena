# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Player, type: :model do
  subject { described_class.new(nickname: 'Any', password: 'Any') }

  it { is_expected.to validate_presence_of(:nickname) }
  it { is_expected.to validate_uniqueness_of(:nickname) }
  it { is_expected.to validate_presence_of(:password) }

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
