# frozen_string_literal: true

module SessionManager
  extend ActiveSupport::Concern

  def authenticate_player!
    token = request.headers['Authorization']

    raise 'Token is missing' unless token

    @current_player = authenticate_player_with_token(token)
  end

  def current_player
    raise 'Unauthorized' unless defined?(@current_player)

    @current_player
  end

  private

  def authenticate_player_with_token(token)
    player = Player.find_by(session: token)

    raise 'Invalid token' unless player
    raise 'Token expired' unless player.session_expires_at
    raise 'Token expired' if player.session_expires_at < Time.current

    player
  end
end
