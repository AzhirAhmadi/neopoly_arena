# frozen_string_literal: true

class Player < ApplicationRecord
  validates :nickname, presence: true, uniqueness: true
  validates :password, presence: true
end
