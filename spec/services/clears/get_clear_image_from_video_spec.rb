require 'rails_helper'
require 'support/shared_examples/invalid_video'

describe Clears::GetClearImageFromVideo do
  let(:service) { described_class.new(video) }
  let(:result) { service.call }

  include_examples 'invalid video'

  context 'when video is valid' do
    let(:video_url) { 'https://www.youtube.com/watch?v=aAfeBGKoZeI&t=34s' }
    let(:video_timestamp) { '34' }
    let(:video) do
      instance_double(Video, to_url: video_url, valid?: true, timestamp: video_timestamp)
    end
    let(:download_url) { 'download_url' }

    before do
      allow(Open3)
        .to receive(:capture2)
        .with('yt-dlp', '-f', '22', '-g', video_url)
        .and_return(get_download_url_result)
    end

    context 'when failed to get download video url' do
      let(:get_download_url_result) { [download_url, double(success?: false)] }

      it 'returns failure' do
        expect(result.failure).to eq(:failed_to_get_download_url)
      end
    end

    context 'when succeeded to get download video url' do
      let(:get_download_url_result) { [download_url, double(success?: true)] }
      let(:clear_image_path) { 'tmp/clearxyz.jpg' }

      before do
        allow(Utils)
          .to receive(:generate_tmp_path)
          .with(prefix: 'clear', suffix: '.jpg')
          .and_return(clear_image_path)
        allow(service)
          .to receive(:system)
          .and_return(extract_image_result)
      end

      context 'when failed to extract image' do
        let(:extract_image_result) { false }

        it 'returns failure' do
          expect(result.failure).to eq(:failed_to_extract_image)
        end
      end

      context 'when succeeded to extract image' do
        let(:extract_image_result) { true }

        it 'returns image path' do
          expect(result.value!).to eq(clear_image_path)
        end

        it 'calls script correctly' do
          result
          expect(service).to have_received(:system).with(
            'ffmpeg', '-ss', video_timestamp, '-i', download_url, '-t', '1', '-y', '-r', '1', clear_image_path
          )
        end
      end
    end
  end
end
