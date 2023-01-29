require 'rails_helper'

RSpec.describe UsedOperator, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:operator) }
    it { is_expected.to belong_to(:clear) }
  end
end
