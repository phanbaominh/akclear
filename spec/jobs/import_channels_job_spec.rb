require 'rails_helper'

describe ImportChannelsJob do
  let_it_be(:existing_channel) do
    create(:channel, external_id: 'existing')
  end
  let_it_be(:clear_with_new_channel, reload: true) do
    create(:clear, link: 'https://youtube.com/watch?v=new', channel: nil)
  end
  let_it_be(:clear_with_existing_channel, reload: true) do
    create(:clear, link: 'https://youtube.com/watch?v=existing', channel: nil)
  end

  let(:channel_data) do
    [instance_double(
      Yt::Models::Composition,
      id: 'new_channel',
      thumbnail_url: 'thumbnail', banner_url: 'banner',
      uploads_playlist_id: 'UUWwuijyo4x78iXup5hOvkbw', title: 'title'
    )]
  end

  before do
    where_simple_videos = instance_double(Yt::Collections::SimpleVideos)
    allow(Yt::Collections::SimpleVideos)
      .to receive(:new)
      .and_return(where_simple_videos)
    allow(where_simple_videos).to receive(:where).with(id: %w[new existing]).and_return(
      [
        instance_double(Yt::Video, channel_id: 'new_channel', id: 'new'),
        instance_double(Yt::Video, channel_id: 'existing', id: 'existing')
      ]
    )
    allow(Yt::Models::ChannelMeta)
      .to receive(:new)
      .with(id: ['new_channel'])
      .and_return(instance_double(Yt::Models::ChannelMeta, compositions: channel_data))
  end

  it 'creates new channels only' do
    expect { described_class.perform_later }.to change(Channel, :count).by(1)

    channel = Channel.last
    expect(channel).to have_attributes(
      title: 'title',
      external_id: 'new_channel',
      thumbnail_url: 'thumbnail',
      banner_url: 'banner',
      uploads_playlist_id: 'UUWwuijyo4x78iXup5hOvkbw'
    )
  end

  it 'assigns channels to clears' do
    described_class.perform_later

    expect(clear_with_existing_channel.reload.channel).to eq(existing_channel)
    expect(clear_with_new_channel.reload.channel).to eq(Channel.last)
  end

  context 'when error' do
    it 'logs error' do
      allow_any_instance_of(Channel).to receive(:save).and_return(false)
      allow_any_instance_of(Channel).to receive_message_chain(:errors, :full_messages, :first).and_return('error')
      allow(Rails.logger).to receive(:warn)

      described_class.perform_later

      expect(Rails.logger).to have_received(:warn).with('[ImportChannelsJob] Failed to create channel: error')
    end
  end
end
