require 'rails_helper'

RSpec.describe Annihilation, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:stages).dependent(:nullify) }
  end

  describe '.latest' do
    let_it_be(:annihilation_1) { create(:annihilation, end_time: 2.days.from_now) }
    let_it_be(:annihilation_2) { create(:annihilation, end_time: 1.day.from_now) }
    let_it_be(:annihilation_3) { create(:annihilation, end_time: 2.days.ago) }

    it 'returns annihilation with latest end_time' do
      expect(described_class.latest).to eq([annihilation_1, annihilation_2])
    end
  end
end
