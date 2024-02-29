# frozen_string_literal: true

class ApplicationController < ActionController::API
  include SessionManager

  before_action :authenticate_player!

  rescue_from 'StandardError' do |exception|
    render json: { error: exception.message }, status: :unauthorized
  end
end
