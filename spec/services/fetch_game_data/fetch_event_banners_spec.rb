require 'rails_helper'
require_relative './image_storable'

describe FetchGameData::FetchEventBanners do
  let_it_be(:ideal_city_summer_event) do
    create(:event, game_id: 'test_act20side')
  end
  let(:cn_events_data) do
    {
      'basicInfo' => {
        'test_act20side' => {
          'name' => '理想城：长夏狂欢季'
        },

        'non-existing' => {
          'name' => 'abc'
        }
      }
    }
  end

  let(:banners_page) do
    <<~HTML
      <tr style="">
        <td>2022-01-25 16:00
        </td>
        <td><a>理想城：长夏狂欢季</a>
        </td>
        <td>
          <a></a>
        </td>
        <td>
          <a>
            <img
            data-src="/images/thumb/f/fb/%E6%B4%BB%E5%8A%A8%E9%A2%84%E5%91%8A_%E5%9B%9B%E5%91%A8%E5%B9%B4%E5%BA%86%E5%85%B8_29.jpg/650px-%E6%B4%BB%E5%8A%A8%E9%A2%84%E5%91%8A_%E5%9B%9B%E5%91%A8%E5%B9%B4%E5%BA%86%E5%85%B8_29.jpg">
          </a>
        </td>
      </tr>
    HTML
  end
  let(:service) { described_class.new }

  before do
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/zh_CN/gamedata/excel/activity_table.json')
      .and_return(Dry::Monads::Success(cn_events_data))
    allow(URI).to receive(:parse).and_return(double(open: 'image file'))
    allow(URI).to receive(:parse).with('https://prts.wiki/w/%E6%B4%BB%E5%8A%A8%E4%B8%80%E8%A7%88').and_return(double(open: banners_page))
    allow(IO).to receive(:copy_stream)
  end

  it 'stores images for existing events' do
    service.call

    expect(URI).to have_received(:parse).with('https://prts.wiki/images/thumb/f/fb/%E6%B4%BB%E5%8A%A8%E9%A2%84%E5%91%8A_%E5%9B%9B%E5%91%A8%E5%B9%B4%E5%BA%86%E5%85%B8_29.jpg/1300px-%E6%B4%BB%E5%8A%A8%E9%A2%84%E5%91%8A_%E5%9B%9B%E5%91%A8%E5%B9%B4%E5%BA%86%E5%85%B8_29.jpg')
    expect(URI).to have_received(:parse).exactly(2).times

    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_act20side.jpg'))
    expect(IO).to have_received(:copy_stream).exactly(1).times
  end

  include_examples 'image_storable' do
    let(:overwritten_image_name) { 'test_act20side' }
  end
end
