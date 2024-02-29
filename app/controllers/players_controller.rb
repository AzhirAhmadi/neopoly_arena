# frozen_string_literal: true

class PlayersController < ApplicationController
  skip_before_action :authenticate_player!, only: :create

  def create
    new_player = Player.new(player_params)

    if new_player.save
      render json: new_player, status: :created
    else
      render json: new_player.errors, status: :unprocessable_entity
    end
  end

  private

  def player_params
    params.permit(:nickname, :password)
  end
end
