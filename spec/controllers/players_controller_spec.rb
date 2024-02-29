# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayersController, type: :controller do
  describe 'POST #create' do
    subject { post :create, params: attributes }

    let(:attributes) do
      {
        nickname: 'nickname',
        password: 'password'
      }
    end

    before do |example|
      subject unless example.metadata[:skip_subject_call]
    end

    context 'when the request is valid' do
      it 'creates a new player', :skip_subject_call do
        expect { subject }.to change(Player, :count).by(1)
      end

      it 'returns 201' do
        expect(response).to have_http_status(:created)
      end

      it 'returns the player' do
        expect(json_body[:nickname]).to eq(attributes[:nickname])
      end
    end

    context 'when the request is invalid' do
      context 'when the nickname is missing' do
        let(:attributes) { super().except(:nickname) }

        it 'does not create a new player', :skip_subject_call do
          expect { subject }.not_to change(Player, :count)
        end

        it 'returns 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns the error message' do
          expect(json_body[:nickname]).to eq(["can't be blank"])
        end
      end

      context 'when the password is missing' do
        let(:attributes) { super().except(:password) }

        it 'does not create a new player', :skip_subject_call do
          expect { subject }.not_to change(Player, :count)
        end

        it 'returns 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns the error message' do
          expect(json_body[:password]).to eq(["can't be blank"])
        end
      end

      context 'when the nickname is already taken', :skip_subject_call do
        before { create(:player, nickname: attributes[:nickname]) }

        it 'does not create a new player' do
          expect { subject }.not_to change(Player, :count)
        end

        it 'returns 422' do
          subject

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns the error message' do
          subject

          expect(json_body[:nickname]).to eq(['has already been taken'])
        end
      end
    end
  end
end
