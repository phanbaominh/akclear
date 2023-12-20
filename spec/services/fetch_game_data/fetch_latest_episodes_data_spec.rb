require 'rails_helper'
require 'dry/monads'

describe FetchGameData::FetchLatestEpisodesData do
  let(:mainline_zone) do
    {
      'zoneID' => 'main_0',
      'type' => 'MAINLINE',
      'zoneNameSecond' => 'Evil Time Part 1'
    }
  end
  let(:non_mainline_zone) do
    {

      'zoneID' => 'weekly_1',
      'type' => 'WEEKLY'

    }
  end
  let(:episodes_data) do
    {
      'zones' => {
        'main_0' => mainline_zone,
        'weekly_1' => non_mainline_zone
      }
    }
  end
  let(:service) { described_class.new }

  before do
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/zone_table.json')
      .and_return(Dry::Monads::Success(episodes_data))
  end

  it 'creates episodes for MAINLINE zones' do
    service.call

    expect(Episode.find_by(game_id: 'main_0')).to have_attributes(
      number: 0,
      name: 'Evil Time Part 1'
    )
  end

  it 'does not create episodes for non-MAINLINE zones' do
    service.call

    expect(Episode.count).to be(1)
    expect(Episode.find_by(game_id: 'weekly_1')).not_to be_present
  end

  context 'when json param is true' do
    let(:service) { described_class.new(json: true) }

    it 'returns correct json' do
      result = service.call.value!

      expect(result).to match(
        [{ game_id: 'main_0', name: 'Evil Time Part 1', number: '0' }]
      )
    end
  end
end
