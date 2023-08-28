require 'rails_helper'

describe Video do
  let(:video_url) { 'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34' }
  let(:video) { described_class.new(video_url) }

  describe '#valid?' do
    context 'when url is valid' do
      it 'returns true' do
        expect(video).to be_valid
      end
    end

    context 'when url is invalid' do
      let(:video_url) { 'https://www.youtubex.com/watch?v=aAfeBGKoZeI&t=34' }

      it 'returns false' do
        expect(video).not_to be_valid
      end

      it 'raises an error when accessing url' do
        expect { video.to_url }.to raise_error(Video::InvalidUrl)
      end
    end
  end

  describe '#to_url' do
    it 'returns the url' do
      expect(video.to_url).to eq(video_url)
    end
  end

  describe '#timestamp' do
    it 'returns the timestamp' do
      expect(video.timestamp).to eq('34')
    end
  end

  describe 'metadata' do
    before do
      allow(Yt::Video).to receive(:new).with(url: video_url).and_return(metadata)
    end

    describe '#title' do
      let(:metadata) { double(title: 'title') }

      it 'returns the title' do
        expect(video.title).to eq('title')
      end
    end
  end
end
