# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_player!

  def create
    SignIn.call(**login_params.to_h) do |result|
      result.success do |session|
        render json: { access_token: session }, status: :ok
      end

      result.failure do |error|
        render json: { error: error }, status: :unauthorized
      end
    end
  end

  private

  def login_params
    params.permit(:nickname, :password)
  end
end
