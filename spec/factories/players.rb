# frozen_string_literal: true

FactoryBot.define do
  factory :player do
    sequence(:nickname) { |n| "player#{n}" }
    password { 'password' }

    trait :with_session do
      session { 'token' }
      session_expires_at { 1.day.from_now }
    end

    trait :expired_session do
      session { 'expired token' }
      session_expires_at { 1.day.ago }
    end
  end
end
