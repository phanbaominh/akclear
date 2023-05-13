require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:stages).dependent(:nullify) }
  end

  describe '.latest' do
    let_it_be(:event_1) { create(:event, end_time: 2.days.from_now) }
    let_it_be(:event_2) { create(:event, end_time: 1.day.from_now) }
    let_it_be(:event_3) { create(:event, end_time: 2.days.ago) }

    it 'returns event with latest end_time' do
      expect(described_class.latest).to eq([event_1, event_2])
    end
  end
end
