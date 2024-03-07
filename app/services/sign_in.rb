# frozen_string_literal: true

class SignIn < ApplicationService
  option :nickname, Types::String
  option :password, Types::String

  def call
    player = Player.find_by(nickname: nickname, password: password)

    return Failure('Invalid nickname or password') unless player

    player.update!(session: SecureRandom.hex, session_expires_at: 1.day.from_now)

    Success(player.session)
  end
end
