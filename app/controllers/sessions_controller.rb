# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_player!

  def create
    session = Player.sing_in(login_params[:nickname], login_params[:password])

    render json: { access_token: session }, status: :ok
  rescue StandardError => exception
    render json: { error: exception.message }, status: :unauthorized
  end

  private

  def login_params
    params.permit(:nickname, :password)
  end
end
