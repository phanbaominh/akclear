require 'rails_helper'

RSpec.describe Channel do
  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:clears).dependent(:nullify) }
  end

  it 'stub requests' do
    channel_id = 'UCK2punOBsp-ogaGUcSKPgBg&key=AIzaSyBqf-dQKzlfjUF052V9vUg_vYkkzKHG5dg'
    channel_data = Yt::Models::ChannelMeta.new(id: channel_id)
    expect { channel_data.thumbnail_url }.to raise_error(WebMock::NetConnectNotAllowedError)
  end

  describe '.from' do
    let(:link) { 'https://www.youtube.com/watch?v=123&' }

    before do
      allow(Yt::Video).to receive(:new).and_return(video_data)
    end

    context 'when the channel exists' do
      let_it_be(:channel) { create(:channel, external_id: 'abc') }
      let(:video_data) { double(channel_id: 'abc') }

      it 'returns the channel' do
        expect(described_class.from(link)).to eq(channel)
      end
    end

    context 'when the channel does not exist' do
      let(:video_data) { double(channel_id: 'abc', channel_title: 'title') }
      let(:channel_data) do
        instance_double(Yt::Models::ChannelMeta, thumbnail_url: 'thumbnail', banner_url: 'banner',
                                                 uploads_playlist_id: 'UUWwuijyo4x78iXup5hOvkbw')
      end

      before do
        allow(Yt::Models::ChannelMeta).to receive(:new).and_return(channel_data)
      end

      it 'initializes a new channel' do
        new_channel = described_class.from(link)
        expect(new_channel).to be_new_record
        expect(new_channel).to have_attributes(
          title: 'title',
          external_id: 'abc',
          thumbnail_url: 'thumbnail',
          banner_url: 'banner',
          uploads_playlist_id: 'UUWwuijyo4x78iXup5hOvkbw'
        )
      end
    end
  end
end
