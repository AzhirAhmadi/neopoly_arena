# frozen_string_literal: true

require 'rails_helper'

class TestController < ApplicationController
  skip_before_action :authenticate_player!, only: :unprotected_action

  def protected_action
    render json: current_player, status: :ok
  end

  def unprotected_action
    render json: { message: 'ok' }, status: :ok
  end
end

RSpec.describe TestController, type: :controller do
  let(:authorized_player) { create(:player, :with_session) }
  let(:expired_token) { create(:player, :expired_session).session }

  before do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get 'protected_action' => 'test#protected_action'
      get 'unprotected_action' => 'test#unprotected_action'
    end
  end

  describe 'SessionManager.include' do
    before { request.headers['Authorization'] = token }

    context 'for protected action' do
      before { get :protected_action }

      context 'when the token is missing' do
        let(:token) { nil }

        it 'returns 401' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns the error message' do
          expect(json_body).to eq({ error: 'Token is missing' })
        end
      end

      context 'when the token is invalid' do
        let(:token) { 'invalid_token' }

        it 'returns 401' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns the error message' do
          expect(json_body).to eq({ error: 'Invalid token' })
        end
      end

      context 'when the token is expired' do
        let(:token) { expired_token }

        it 'returns 401' do
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns the error message' do
          expect(json_body).to eq({ error: 'Token expired' })
        end
      end

      context 'when the token is valid' do
        let(:token) { authorized_player.session }

        it 'returns 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the player' do
          expect(json_body[:id]).to eq(authorized_player.id)
        end
      end
    end

    context 'for unprotected action' do
      before { get :unprotected_action }

      context 'when the token is missing' do
        let(:token) { nil }

        it 'returns 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the message' do
          expect(json_body).to eq({ message: 'ok' })
        end
      end

      context 'when the token is invalid' do
        let(:token) { 'invalid_token' }

        it 'returns 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the message' do
          expect(json_body).to eq({ message: 'ok' })
        end
      end

      context 'when the token is expired' do
        let(:token) { expired_token }

        it 'returns 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the message' do
          expect(json_body).to eq({ message: 'ok' })
        end
      end

      context 'when the token is valid' do
        let(:token) { authorized_player.session }

        it 'returns 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the message' do
          expect(json_body).to eq({ message: 'ok' })
        end
      end
    end
  end
end
