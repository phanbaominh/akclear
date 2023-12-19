require 'rails_helper'

RSpec.describe UsedOperator, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:operator) }
    it { is_expected.to belong_to(:clear) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:skill).in_range(1..3).allow_nil }
    it { is_expected.to validate_numericality_of(:level).is_in(1..90).allow_nil }
    it { is_expected.to validate_inclusion_of(:elite).in_range(0..2).allow_nil }
    it { is_expected.to validate_inclusion_of(:skill_level).in_range(1..10).allow_nil }
  end
end
