require 'rails_helper'

RSpec.describe Clear, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:submitter) }
    it { is_expected.to belong_to(:stage) }
    it { is_expected.to belong_to(:player) }
  end
end
