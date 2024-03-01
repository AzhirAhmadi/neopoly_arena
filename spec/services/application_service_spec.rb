# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationService do
  describe '.call' do
    subject { described_class.call }

    it { is_expected.to be_failure }
  end
end
