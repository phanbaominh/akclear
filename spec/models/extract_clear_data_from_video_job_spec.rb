require 'rails_helper'
require 'aasm/rspec'

RSpec.describe ExtractClearDataFromVideoJob, type: :model do
  describe 'aasm' do
    subject { described_class.new }

    it { is_expected.to have_state(:pending) }
    it { is_expected.to transition_from(:pending).to(:processing).on_event(:process) }
    it { is_expected.to transition_from(:processing).to(:completed).on_event(:complete) }
    it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
  end
end
