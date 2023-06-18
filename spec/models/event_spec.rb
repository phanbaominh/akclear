require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:stages).dependent(:nullify) }
    it { is_expected.to belong_to(:original_event).class_name('Event').optional }

    it {
      is_expected # rubocop:disable RSpec/ImplicitSubject
        .to have_one(:rerun_event)
        .class_name('Event').with_foreign_key(:original_event_id).dependent(:nullify).inverse_of(:original_event)
    }
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
