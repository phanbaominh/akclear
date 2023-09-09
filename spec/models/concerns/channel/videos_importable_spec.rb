require 'rails_helper'

describe Channel::VideosImportable do
  describe '.import_videos' do
    let(:spec_satisfy_result) { double }
    let(:channels) { double }
    let(:spec) do
      double(Channel::VideosImportSpecification, channels:,
                                                 satisfy?: spec_satisfy_result)
    end
    let(:specified_channel) { create(:channel) }
    let(:video_data) { instance_double(Yt::PlaylistItem) }

    it 'imports videos from specified channels that sastify the specfications' do
      allow(channels).to receive(:find_each).and_yield(specified_channel)
      allow(specified_channel).to receive(:import_videos) { |&block|
                                    expect(block.call(video_data)).to eq(spec_satisfy_result)
                                  }
      Channel.import_videos(spec)

      expect(specified_channel).to have_received(:import_videos)
      expect(spec).to have_received(:satisfy?).with(video_data)
    end
  end

  describe '#import_videos' do
    let(:channel) { create(:channel) }
    let(:playlist) { instance_double(Yt::Playlist) }
    let(:valid_playlist_item) { instance_double(Yt::PlaylistItem, video_id: 'ygEmeAtWYvA') }
    let(:invalid_playlist_item) { instance_double(Yt::PlaylistItem, video_id: 'ygEmeAtWYvA&invalid=param') }
    let(:unselected_playlist_item) { instance_double(Yt::PlaylistItem) }
    let(:video) { instance_double(Video) }

    before do
      allow(Yt::Playlist).to receive(:new).and_return(playlist)
      allow(playlist).to receive(:playlist_items).and_return([unselected_playlist_item, valid_playlist_item,
                                                              invalid_playlist_item])
    end

    it 'creates extract clear data job only from valid videos' do
      expect(ExtractClearDataFromVideoJob.count).to eq(0)
      channel.import_videos do |video|
        [valid_playlist_item, invalid_playlist_item].include?(video)
      end

      expect(ExtractClearDataFromVideoJob.find_by(video_url: 'https://youtube.com/watch?v=ygEmeAtWYvA')).to be_present
    end
  end
end
