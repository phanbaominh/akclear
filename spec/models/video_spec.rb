require 'rails_helper'

describe Video do
  let(:video_url) { 'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34' }
  let(:video) { described_class.new(video_url) }

  describe '#from_id' do
    it 'returns a video with the normalized url' do
      video = described_class.from_id('aAfeBGKoZeI')

      expect(video.to_url).to eq('https://youtube.com/watch?v=aAfeBGKoZeI')
    end
  end

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
    end

    context 'when url has invalid params' do
      let(:video_url) { 'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34&invalid=param' }

      it 'returns false' do
        expect(video).not_to be_valid
      end
    end
  end

  describe '#to_url' do
    context 'when normalized is true' do
      [
        'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34',
        'https://youtu.be/aAfeBGKoZeI?t=34'
      ].each do |url|
        let(:video_url) { url }
        it 'returns the normalized url' do
          expect(video.to_url(normalized: true)).to eq 'https://youtube.com/watch?v=aAfeBGKoZeI'
        end
      end
    end

    context 'when normalized is false' do
      it 'returns the url' do
        expect(video.to_url).to eq(video_url)
      end
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

    describe '#stage_id' do
      let_it_be(:stage) { create(:stage, code: 'CODE', game_id: 'gameid') }
      let_it_be(:challenge_mode_stage) { create(:stage, code: 'CODE', game_id: '#f#gameid') }
      let_it_be(:wrong_code_stage) { create(:stage, code: 'WRONG', game_id: 'wgameid') }

      let(:metadata) { double(title: 'CODE | title') }

      it 'returns the stage with correct code' do
        expect(video.stage_id).to eq(challenge_mode_stage.id)
      end
    end
  end
end
