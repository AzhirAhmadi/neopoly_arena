# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SingIn do
  describe '#call' do
    subject(:sing_in) { described_class.call(**attributes) }

    let(:player) { create(:player) }
    let(:attributes) { { nickname: nickname, password: password } }
    let(:nickname) { player.nickname }
    let(:password) { player.password }

    context 'when the nickname and password are correct' do
      before do |example|
        sing_in unless example.metadata[:skip_sign_in]

        player.reload
      end

      it 'returns a success' do
        expect(sing_in).to be_success
      end

      it 'returns a session', :skip_sign_in do
        expect(sing_in.value!).to eq(player.reload.session)
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
          expect(described_class.call(**attributes).value!).not_to eq(player.session)
        end
      end
    end

    context 'when the nickname and password are incorrect' do
      context 'when the nickname is incorrect' do
        let(:nickname) { 'Incorrect' }

        it 'returns a failure' do
          expect(sing_in).to be_failure
        end

        it 'has an error message' do
          expect(sing_in.failure).to eq('Invalid nickname or password')
        end
      end

      context 'when the password is incorrect' do
        let(:password) { 'Incorrect' }

        it 'returns a failure' do
          expect(sing_in).to be_failure
        end

        it 'has an error message' do
          expect(sing_in.failure).to eq('Invalid nickname or password')
        end
      end
    end
  end
end
