# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    owner { association :player }
    turn { 'owner' }
    board { '_' * 8 * 8 }

    trait :pending do
      status { :pending }
      opponent { nil }
    end

    trait :in_progress do
      pending
      status { :in_progress }
      opponent { association :player }
    end

    trait :owner_won do
      in_progress
      status { :complete }
      winner { owner }
    end

    trait :owner_lost do
      in_progress
      status { :complete }
      winner { opponent }
    end

    trait :opponent_won do
      in_progress
      status { :complete }
      winner { opponent }
    end

    trait :opponent_lost do
      in_progress
      status { :complete }
      winner { owner }
    end

    trait :drawn do
      in_progress
      status { :complete }
      winner { nil }
    end
  end
end
