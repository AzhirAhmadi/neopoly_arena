# frozen_string_literal: true

class GamesController < ApplicationController
  def index
    Games::Index.call(**{ limit: params[:limit]&.to_i, offset: params[:offset]&.to_i }.compact) do |result|
      result.success do |value|
        render json: value, status: :ok
      end

      result.failure do |error|
        render json: error, status: :unprocessable_entity
      end
    end
  end

  def show
    render json: game, status: :ok
  end

  def create
    Games::Create.call(player: current_player) do |result|
      result.success do |value|
        render json: value, status: :created
      end

      result.failure do |error|
        render json: error, status: :unprocessable_entity
      end
    end
  end

  def join
    Games::Join.call(game: game, opponent: current_player) do |result|
      result.success do |value|
        render json: value, status: :created
      end

      result.failure do |error|
        render json: error, status: :unprocessable_entity
      end
    end
  end

  def drop_coin
    attributes = {
      game: game,
      player: current_player,
      move: params[:move]
    }.compact

    Games::DropCoin.call(**attributes) do |result|
      result.success do |value|
        render json: value, status: :ok
      end

      result.failure do |error|
        render json: error, status: :unprocessable_entity
      end
    end
  end

  private

  def game
    @_game ||= Game.find(params[:id] || params[:game_id])
  end
end
