require 'rails_helper'
require 'aasm/rspec'

RSpec.describe ExtractClearDataFromVideoJob, type: :model do
  describe 'enum' do
    describe 'status' do
      it {
        is_expected
          .to define_enum_for(:status)
          .with_values(pending: 0, processing: 1, completed: 2, failed: 3, clear_created: 4)
      }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:stage) }
  end

  describe 'aasm' do
    subject { described_class.new }

    it { is_expected.to have_state(:pending) }
    it { is_expected.to transition_from(:pending).to(:processing).on_event(:start) }
    it { is_expected.to transition_from(:processing).to(:completed).on_event(:complete) }
    it { is_expected.to transition_from(:completed).to(:clear_created).on_event(:mark_clear_created) }
    it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
  end
end
