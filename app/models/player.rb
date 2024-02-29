# frozen_string_literal: true

class Player < ApplicationRecord
  validates :nickname, presence: true, uniqueness: true
  validates :password, presence: true

  def self.sing_in(nickname, password)
    player = find_by(nickname: nickname, password: password)

    raise 'Invalid nickname or password' unless player

    player.update!(session: SecureRandom.hex, session_expires_at: 1.day.from_now)

    player.session
  end
end
