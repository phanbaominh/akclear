require 'rails_helper'
require_relative 'image_storable'

describe FetchGameData::FetchEpisodesBanners do
  let_it_be(:prologue) do
    create(:episode, game_id: 'test_main_0', number: 0)
  end
  let_it_be(:episode_1) do
    create(:episode, game_id: 'test_main_1', number: 1)
  end
  let_it_be(:episode_12) do
    create(:episode, game_id: 'test_main_12', number: 12)
  end
  let(:banners_page) do
    <<~HTML
      <img alt="Prologue: Evil time Part 1"
      src="https://static.wikia.nocookie.net/mrfz/images/f/f8/Prologue.png/revision/latest?cb=20220418161704">
      <th>
        <a>
          <img alt="Prologue.png"
          src="/link0">
        </a>
      </th>
      <th>
        <a>
          <img alt="Episode 01.png"
          src="/link1">
        </a>
      </th>
      <th>
        <a>
          <img alt="Episode 12.png"
          src="/link12"
          >
        </a>
      </th>
    HTML
  end
  let(:service) { described_class.new }

  before do
    episodes = [
      prologue, episode_1, episode_12
    ].map(&:attributes).map { |attrs| attrs.transform_keys(&:to_sym).slice(:game_id, :number) }
    allow(FetchGameData::FetchLatestEpisodesData).to receive(:call).and_return(Dry::Monads::Success(episodes))
    allow(URI).to receive(:parse).and_return(double(open: 'image file'))
    allow(URI).to receive(:parse).with('https://arknights.wiki.gg/wiki/Operation/Main_Theme').and_return(double(open: banners_page))
    allow(IO).to receive(:copy_stream)
  end

  it 'stores images for existing episodes' do
    service.call

    expect(URI).to have_received(:parse).with('https://arknights.wiki.gg/wiki/Operation/Main_Theme')
    expect(URI).to have_received(:parse).with('https://arknights.wiki.gg/link1')
    expect(URI).to have_received(:parse).with('https://arknights.wiki.gg/link0')
    expect(URI).to have_received(:parse).with('https://arknights.wiki.gg/link12')
    expect(URI).to have_received(:parse).exactly(4).times

    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_main_0.jpg'))
    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_main_1.jpg'))
    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_main_12.jpg'))
    expect(IO).to have_received(:copy_stream).exactly(3).times
  end

  include_examples 'image_storable' do
    let(:overwritten_image_name) { 'test_main_0' }
  end
end
