require 'rails_helper'

RSpec.describe ExtractClearDataFromVideoJobRunner do
  let_it_be(:job, reload: true) do
    create(
      :extract_clear_data_from_video_job,
      video_url: 'https://www.youtube.com/watch?v=9bZkp7q19f0',
      status: :started,
      channel: create(:channel),
      data: { 'name' => 'title' }
    )
  end

  describe 'config' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    after { ActiveJob::Base.queue_adapter = :inline }

    it 'has queue as system' do
      expect { described_class.perform_later(job.id) }.to have_enqueued_job.on_queue('system_serial')
    end
  end

  describe '#perform_later' do
    before do
      allow(Clears::BuildClearFromVideo).to receive(:call).and_return(result)
    end

    context 'when job is not started' do
      let(:result) { double }

      it 'does nothing' do
        job.update!(status: :pending)
        described_class.perform_later(job.id)
        expect(Clears::BuildClearFromVideo).not_to have_received(:call)
      end
    end

    context 'when success' do
      let(:result) { Dry::Monads::Success(build(:clear)) }

      it 'extracts clear data from video' do
        described_class.perform_later(job.id)
        expect(Clears::BuildClearFromVideo).to have_received(:call).with(job.video,
                                                                         operator_name_only: job.operator_name_only)
        expect(job.reload.data).to eq(
          result.value!.attributes.slice('link')
            .merge('used_operators_attributes' => [], 'channel_id' => job.channel_id, 'name' => 'title', 'stage_id' => job.stage.id)
        )
        expect(job.reload).to be_completed
      end
    end

    context 'when failure' do
      let(:result) { Dry::Monads::Failure(:invalid_video) }

      it 'stores error' do
        described_class.perform_later(job.id)
        expect(Clears::BuildClearFromVideo).to have_received(:call).with(job.video,
                                                                         operator_name_only: job.operator_name_only)
        expect(job.reload.data).to eq({ 'error' => 'invalid_video', 'name' => 'title' })
        expect(job).to be_failed
      end
    end

    context 'when exception' do
      let(:result) { double }

      before do
        allow(Clears::BuildClearFromVideo).to receive(:call).and_raise(StandardError, 'error')
      end

      it 'stores error' do
        described_class.perform_later(job.id)
        expect(Clears::BuildClearFromVideo).to have_received(:call).with(job.video,
                                                                         operator_name_only: job.operator_name_only)
        expect(job.reload.data).to eq({ 'error' => 'error', 'name' => 'title' })
        expect(job).to be_failed
      end
    end
  end
end
