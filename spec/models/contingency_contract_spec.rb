require 'rails_helper'

RSpec.describe ContingencyContract, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:risks) }
  end
end
