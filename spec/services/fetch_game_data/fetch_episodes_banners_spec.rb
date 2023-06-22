require 'rails_helper'
require_relative './image_storable'

describe FetchGameData::FetchEpisodesBanners do
  let_it_be(:prologue) do
    create(:episode, game_id: 'test_main_0', name: 'Evil Time Part 1')
  end
  let_it_be(:episode_3) do
    create(:episode, game_id: 'test_main_3', name: 'Stinging Shock')
  end
  let(:banners_page) do
    <<~HTML
      <img alt="Prologue: Evil time Part 1"
      src="https://static.wikia.nocookie.net/mrfz/images/f/f8/Prologue.png/revision/latest?cb=20220418161704">
      <th>
        <a>
          <img alt="Prologue: Evil Time Part 1"
          src="https://static.wikia.nocookie.net/mrfz/images/f/f8/Prologue.png/revision/latest?cb=20220418161704">
        </a>
      </th>
      <th>
        <a>
          <img alt="Episode 1: Evil Time Part 2"
          src="link">
        </a>
      </th>
      <th>
        <a>
          <img alt="Episode 3: Stinging Shock"
          src="data:image/gif;base64,R0lGODlhAQABAIABAAAAAP///yH5BAEAAAEALAAAAAABAAEAQAICTAEAOw%3D%3D"
          data-src="episode_3_link">
        </a>
      </th>
    HTML
  end
  let(:service) { described_class.new }

  before do
    allow(URI).to receive(:parse).and_return(double(open: 'image file'))
    allow(URI).to receive(:parse).with('https://arknights.fandom.com/wiki/Story/Main_Theme').and_return(double(open: banners_page))
    allow(IO).to receive(:copy_stream)
  end

  it 'stores images for existing episodes' do
    service.call

    expect(URI).to have_received(:parse).with('https://arknights.fandom.com/wiki/Story/Main_Theme')
    expect(URI).to have_received(:parse).with('https://static.wikia.nocookie.net/mrfz/images/f/f8/Prologue.png/revision/latest?cb=20220418161704')
    expect(URI).to have_received(:parse).with('episode_3_link')
    expect(URI).to have_received(:parse).exactly(3).times

    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_main_0.jpg'))
    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_main_3.jpg'))
    expect(IO).to have_received(:copy_stream).exactly(2).times
  end

  include_examples 'image_storable' do
    let(:overwritten_image_name) { 'test_main_0' }
  end
end
