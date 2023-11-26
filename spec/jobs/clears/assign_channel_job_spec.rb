require 'rails_helper'

describe Clears::AssignChannelJob do
  let_it_be(:current_channel) { create(:channel, external_id: 'abc') }
  let_it_be(:clear, reload: true) { create(:clear, channel: current_channel) }
  let(:link) { 'https://youtube.com/watch?v=123' }
  let(:channel) { build(:channel) }

  before do
    allow(described_class).to receive(:perform_later).and_call_original
    allow(Channel).to receive(:from).and_return(channel)
  end

  context 'clear is not found' do
    it 'returns' do
      described_class.perform_later(-1, link)

      expect(Channel).not_to have_received(:from)
    end
  end

  context 'when channel is not found' do
    let(:channel) { nil }

    it 'does not change channel' do
      described_class.perform_later(clear.id, link)

      expect(clear.channel).to eq(current_channel)
    end
  end

  context 'when channel is new' do
    it 'saves the channel' do
      described_class.perform_later(clear.id, link)

      expect(channel).to be_persisted
      expect(clear.reload.channel).to eq(channel)
    end
  end

  context 'when channel is a different existing channel' do
    let(:channel) { create(:channel) }

    it 'saves the channel' do
      described_class.perform_later(clear.id, link)

      expect(clear.reload.channel).to eq(channel)
    end
  end

  context 'when failed to save' do
    it 'logs the error' do
      allow(Clear).to receive(:find_by).with(id: clear.id).and_return(clear)

      allow(Rails.logger).to receive(:error)
      allow(clear).to receive(:save).and_return(false)
      allow(clear).to receive_message_chain(:errors, :full_messages).and_return(['error'])

      described_class.perform_later(clear.id, link)

      expect(Rails.logger)
        .to have_received(:error)
        .with('Could not assign channel to clear: error')
    end
  end
end
