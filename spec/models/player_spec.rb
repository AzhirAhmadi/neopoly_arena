# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Player, type: :model do
  subject { described_class.new(nickname: 'Any', password: 'Any') }

  it { is_expected.to validate_presence_of(:nickname) }
  it { is_expected.to validate_uniqueness_of(:nickname) }
  it { is_expected.to validate_presence_of(:password) }
end
