require 'rails_helper'

describe Channel::VideosImportable do
  describe '.import_videos_from_channels' do
    let(:channels) { double }
    let(:spec) do
      double(Channel::VideosImportSpecification, channels:, reset: nil)
    end
    let(:specified_channel) { create(:channel) }

    it 'imports videos from specified channels that satisfy the specfications' do
      allow(channels).to receive(:find_each).and_yield(specified_channel)
      allow(specified_channel).to receive(:import_videos)

      Channel.import_videos_from_channels(spec)

      expect(specified_channel).to have_received(:import_videos).with(spec)
      expect(spec).to have_received(:reset)
    end
  end

  describe '#import_videos' do
    let_it_be(:channel) { create(:channel) }
    let_it_be(:stage) { create(:stage) }
    let(:playlist) { instance_double(Yt::Playlist) }
    let(:valid_playlist_item) { instance_double(Yt::PlaylistItem, video_id: 'ygEmeAtWYvA') }
    let(:invalid_playlist_item) { instance_double(Yt::PlaylistItem, video_id: 'ygEmeAtWYvA&invalid=param') }
    let(:video) { instance_double(Video, 'metadata=': nil, stage_id: stage.id, to_url: 'https://youtube.com/watch?v=ygEmeAtWYvA', valid?: true, title: 'new title') }
    let(:video_data) { instance_double(Yt::PlaylistItem) }
    let(:spec) do
      instance_double(Channel::VideosImportSpecification)
    end

    before do
      allow(Yt::Playlist).to receive(:new).and_return(playlist)
      allow(spec).to receive(:satisfy?).with(valid_playlist_item).and_return(true)
      allow(spec).to receive(:satisfy?).with(invalid_playlist_item).and_return(false)
      allow(spec).to receive(:stop?).and_return(false, false, true)
      allow(Video).to receive(:from_id).with('ygEmeAtWYvA').and_return(video)
      allow(playlist).to receive(:playlist_items).and_return([valid_playlist_item, invalid_playlist_item])
    end

    it 'creates extract clear data job only from valid videos' do
      expect(ExtractClearDataFromVideoJob.count).to eq(0)
      channel.import_videos(spec)

      expect(video).to have_received(:metadata=).with(valid_playlist_item)

      expect(ExtractClearDataFromVideoJob.count).to eq(1)
      new_job = ExtractClearDataFromVideoJob.first
      expect(new_job.channel).to eq(channel)
      expect(new_job.stage).to eq(stage)
      expect(new_job.video_url).to eq('https://youtube.com/watch?v=ygEmeAtWYvA')
      expect(new_job.data['name']).to eq('new title')
    end
  end
end
