# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'POST #create' do
    subject { post :create, params: attributes }

    let(:player) { create(:player) }
    let(:attributes) do
      {
        nickname: player.nickname,
        password: player.password
      }
    end

    before do |example|
      subject unless example.metadata[:skip_subject_call]
    end

    context 'when the request is valid' do
      it 'returns 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the access token' do
        expect(json_body[:access_token]).to eq(player.reload.session)
      end
    end

    context 'when the request is invalid' do
      context 'when the nickname is missing' do
        let(:attributes) { super().except(:nickname) }

        it 'returns 401' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns the error message' do
          expect(json_body[:error]).to eq("SignIn: option 'nickname' is required")
        end
      end

      context 'when the password is missing' do
        let(:attributes) { super().except(:password) }

        it 'returns 401' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns the error message' do
          expect(json_body[:error]).to eq("SignIn: option 'password' is required")
        end
      end

      context 'when the nickname is invalid' do
        let(:attributes) { super().merge(nickname: 'invalid') }

        it 'returns 401' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns the error message' do
          expect(json_body[:error]).to eq('Invalid nickname or password')
        end
      end

      context 'when the password is invalid' do
        let(:attributes) { super().merge(password: 'invalid') }

        it 'returns 401' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns the error message' do
          expect(json_body[:error]).to eq('Invalid nickname or password')
        end
      end
    end
  end
end
