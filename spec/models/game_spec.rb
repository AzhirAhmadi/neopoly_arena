# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('Player') }
    it { is_expected.to belong_to(:opponent).class_name('Player').optional }
    it { is_expected.to belong_to(:winner).class_name('Player').optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:turn) }
    it { is_expected.to validate_presence_of(:board) }
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:status)
        .backed_by_column_of_type(:string)
        .with_values(pending: 'pending', in_progress: 'in_progress', complete: 'complete')
        .with_suffix
    }

    it {
      expect(subject).to define_enum_for(:turn)
        .backed_by_column_of_type(:string)
        .with_values(owner: 'owner', opponent: 'opponent')
        .with_suffix
    }
  end
end
