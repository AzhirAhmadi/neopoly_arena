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

  def rankings
    Rankings.call(**{ limit: params[:limit]&.to_i, offset: params[:offset]&.to_i }.compact) do |result|
      result.success do |value|
        render json: value, status: :ok
      end

      result.failure do |error|
        render json: error, status: :unprocessable_entity
      end
    end
  end

  private

  def player_params
    params.permit(:nickname, :password)
  end
end
