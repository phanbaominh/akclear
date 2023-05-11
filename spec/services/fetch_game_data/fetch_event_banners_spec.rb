require 'rails_helper'
require_relative './image_storable'

describe FetchGameData::FetchEventBanners do
  let_it_be(:ideal_city_summer_event) do
    create(:event, game_id: 'test_act20side')
  end
  let_it_be(:dossoles_holiday_event) do
    create(:event, game_id: 'test_act12side')
  end
  let_it_be(:invitation_to_wines_event) do
    create(:event, game_id: 'test_act15side')
  end
  let(:cn_events_data) do
    {
      'basicInfo' => {
        'test_act20side' => {
          'name' => '理想城：长夏狂欢季'
        },
        'test_act12side' => {
          'name' => '多索雷斯假日'
        },
        'test_act15side' => {
          'name' => '将进酒'
        },
        'non-existing' => {
          'name' => 'abc'
        }
      }
    }
  end

  let(:banners_page) do
    <<~HTML
      <td>
        <a>
          <img alt="活动预告 夏活2022 02.jpg"
          data-src="/images/thumb/f/fb/%E6%B4%BB%E5%8A%A8%E9%A2%84%E5%91%8A_%E5%9B%9B%E5%91%A8%E5%B9%B4%E5%BA%86%E5%85%B8_29.jpg/650px-%E6%B4%BB%E5%8A%A8%E9%A2%84%E5%91%8A_%E5%9B%9B%E5%91%A8%E5%B9%B4%E5%BA%86%E5%85%B8_29.jpg">
        </a>
      </td>
      <img alt="多索雷斯假日2022.jpg" data-src="/images/650_test_act12side">
      <td>
        <a>
          <img alt="多索雷斯假日2022.jpg" data-src="/images/650_test_act12side">
        </a>
      </td>
      <td>
      <a>
        <img alt="活动预告 将进酒 15.jpg" data-src="650_test_act15side15">
      </a>
      </td>
      <td>
        <a>
          <img alt="活动预告 将进酒 01.jpg" data-src="/images/650_test_act15side1">
        </a>
      </td>
      <td>
        <a>
          <img alt="活动预告 abc 01.jpg" data-src="650_test_act15side1">
        </a>
      </td>
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
    expect(URI).to have_received(:parse).with('https://prts.wiki/images/1300_test_act12side')
    expect(URI).to have_received(:parse).with('https://prts.wiki/images/1300_test_act15side1')
    expect(URI).to have_received(:parse).exactly(4).times

    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_act20side.jpg'))
    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_act12side.jpg'))
    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/banners/test_act15side.jpg'))
    expect(IO).to have_received(:copy_stream).exactly(3).times
  end

  include_examples 'image_storable' do
    let(:overwritten_image_name) { 'test_act20side' }
  end
end
