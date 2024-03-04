# frozen_string_literal: true

class UpdateElo < ApplicationService
  option :owner, Types.Instance(Player)
  option :opponent, Types.Instance(Player)
  option :result, Types::String

  K = 32.0
  C = 400.0
  E = 10.0

  def call
    yield valid_players?
    yield valid_result?

    owner_elo = r('owner')
    opponent_elo = r('opponent')

    ActiveRecord::Base.transaction do
      owner.update!(elo: owner_elo)
      opponent.update!(elo: opponent_elo)

      Success()
    rescue ActiveRecord::RecordInvalid => exception
      Failure(exception.message)
    end
  end

  private

  def valid_players?
    return Failure('Same players') if owner == opponent

    Success()
  end

  def valid_result?
    return Failure('Invalid result') unless %w(owner opponent draw).include?(result)

    Success()
  end

  def r(player_role)
    elo(player_role) + (K * (s(player_role) - e(player_role)))
  end

  def elo(player_role)
    player_role == 'owner' ? owner.elo : opponent.elo
  end

  def e(player_role)
    numerator = player_role == 'owner' ? q_owner : q_opponent

    numerator / (q_owner + q_opponent)
  end

  def s(player_role)
    return 1.0 if result == player_role
    return 0.5 if result == 'draw'

    0.0
  end

  def q_opponent
    @_q_opponent ||= q(opponent)
  end

  def q_owner
    @_q_owner ||= q(owner)
  end

  def q(player)
    10.0**(player.elo / C)
  end
end
