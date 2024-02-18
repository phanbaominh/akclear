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
    it { is_expected.to belong_to(:channel).optional }
  end

  describe 'aasm' do
    subject { described_class.new }

    it { is_expected.to have_state(:pending) }
    it { is_expected.to transition_from(:pending).to(:started).on_event(:start) }
    it { is_expected.to transition_from(:failed).to(:started).on_event(:start) }
    it { is_expected.to transition_from(:processing).to(:started).on_event(:start) }
    it { is_expected.to transition_from(:started).to(:processing).on_event(:process) }
    it { is_expected.to transition_from(:processing).to(:completed).on_event(:complete) }
    it { is_expected.to transition_from(:completed).to(:clear_created).on_event(:mark_clear_created) }
    it { is_expected.to transition_from(:failed).to(:clear_created).on_event(:mark_clear_created) }
    it { is_expected.to transition_from(:pending).to(:clear_created).on_event(:mark_clear_created) }
    it { is_expected.to transition_from(:processing).to(:failed).on_event(:fail) }
  end

  describe '#video_url=' do
    let_it_be(:channel) { create(:channel, external_id: 'abc') }
    let(:video_url) { 'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34' }
    let(:video) do
      instance_double(Video, stage_id: 1, to_url: video_url, channel_external_id: 'abc', title: 'new title',
                             valid?: true)
    end

    before { allow(Video).to receive(:new).with(video_url).and_return(video) }

    context 'when video is url' do
      let(:job) { described_class.create(video_url:) }

      it 'sets the stage_id' do
        expect(job.stage_id).to eq(1)
      end

      it 'sets the channel' do
        expect(job.channel).to eq(channel)
      end

      it 'sets the title' do
        expect(job.data['name']).to eq('new title')
      end
    end

    context 'when video is Video' do
      let(:job) { described_class.create(video_url: video) }

      it 'sets the stage_id' do
        expect(job.stage_id).to eq(1)
      end

      it 'sets the channel' do
        expect(job.channel).to eq(channel)
      end

      it 'sets the title' do
        expect(job.data['name']).to eq('new title')
      end
    end
  end
end
