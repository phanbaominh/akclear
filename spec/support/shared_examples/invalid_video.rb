RSpec.shared_examples 'invalid video' do
  let(:video) { Video.new('https://www.youtubex.com/watch?v=aAfeBGKoZeI&t=34') }
  context 'when video is invalid' do
    it 'returns failure' do
      expect(result.failure).to eq(:invalid_video)
    end
  end
end
