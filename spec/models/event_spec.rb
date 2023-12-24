require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    subject { build(:event) }

    it { is_expected.to have_many(:stages).dependent(:nullify) }
    it { is_expected.to belong_to(:original_event).class_name('Event').optional }

    it {
      is_expected # rubocop:disable RSpec/ImplicitSubject
        .to have_one(:rerun_event)
        .class_name('Event').with_foreign_key(:original_event_id).dependent(:nullify).inverse_of(:original_event)
    }
  end

  describe 'validations' do
    subject { build(:event) }

    describe 'original_event' do
      context 'when rerun_event? is true' do
        before { subject.name = 'Who Is Real - Rerun' }

        it { is_expected.to validate_presence_of(:original_event) }
      end

      context 'when rerun_event? is false' do
        it { is_expected.not_to validate_presence_of(:original_event) }
      end
    end
  end

  describe '.latest' do
    let_it_be(:event_1) { create(:event, end_time: 1.day.from_now, start_time: 1.day.ago) }
    let_it_be(:event_2) { create(:event, end_time: 2.day.from_now, start_time: 1.day.ago) }
    let_it_be(:event_3) { create(:event, end_time: 2.days.from_now, start_time: 1.day.from_now) }
    let_it_be(:event_4) { create(:event, end_time: 2.days.ago, start_time: 3.days.ago) }

    it 'returns event with latest end_time' do
      expect(described_class.latest).to eq([event_1, event_2])
    end
  end

  describe '#rerun_event?' do
    let(:event) { build_stubbed(:event, name: 'Event') }

    context 'when original_event_id is present' do
      before { event.original_event_id = 1 }

      it 'returns true' do
        expect(event.rerun_event?).to eq(true)
      end
    end

    context 'when name includes Rerun' do
      before { event.name = 'Who Is Real - Rerun' }

      it 'returns true' do
        expect(event.rerun_event?).to eq(true)
      end
    end

    context 'when original_event_id is not present and name does not include Rerun' do
      it 'returns false' do
        expect(event.rerun_event?).to eq(false)
      end
    end
  end
end
