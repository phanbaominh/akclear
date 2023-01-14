require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:stages).dependent(:nullify) }
  end
end
