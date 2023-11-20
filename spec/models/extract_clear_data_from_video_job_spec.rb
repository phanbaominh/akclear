require 'rails_helper'
require 'aasm/rspec'

RSpec.describe ExtractClearDataFromVideoJob, type: :model do
  describe 'enum' do
    describe 'status' do
      it {
        is_expected
          .to define_enum_for(:status)
          .with_values(pending: 0, processing: 1, completed: 2, failed: 3, clear_created: 4, started: 5)
      }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:stage) }
  end

  describe 'aasm' do
    subject { described_class.new }

    it { is_expected.to have_state(:pending) }
    it { is_expected.to transition_from(:pending).to(:started).on_event(:start) }
    it { is_expected.to transition_from(:started).to(:processing).on_event(:process) }
    it { is_expected.to transition_from(:processing).to(:completed).on_event(:complete) }
    it { is_expected.to transition_from(:completed).to(:clear_created).on_event(:mark_clear_created) }
    it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
  end

  describe '#video_url=' do
    let(:video_url) { 'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34' }
    let(:video) { instance_double(Video, stage_id: 1, to_url: video_url) }

    before { allow(Video).to receive(:new).with(video_url).and_return(video) }

    context 'when video is url' do
      let(:job) { described_class.new(video_url:) }

      it 'sets the stage_id' do
        expect(job.stage_id).to eq(1)
      end
    end

    context 'when video is Video' do
      let(:job) { described_class.new(video_url: video) }

      it 'sets the stage_id' do
        expect(job.stage_id).to eq(1)
      end
    end
  end
end
