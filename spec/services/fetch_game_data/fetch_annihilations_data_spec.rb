require 'rails_helper'
require 'dry/monads'

describe FetchGameData::FetchAnnihilationsData do
  let(:annihilation_stage) do
    {
      'stageId' => 'camp_r_01',
      'zoneId' => 'camp_zone_4',
      'name' => 'The Grand Knight Territory Outskirts',
      'stageType' => 'CAMPAIGN'
    }
  end

  let(:episode_stage) do
    {
      'stageType' => 'MAIN',
      'zoneId' => 'main_10',
      'code' => '10-1',
      'isStoryOnly' => false,
      'stageId' => 'main_10-01'
    }
  end
  let(:stages_data) do
    {
      'stages' => {
        'main_10-01' => episode_stage,
        'camp_r_01' => annihilation_stage
      }
    }
  end

  let(:service) { described_class.new }

  before do
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/stage_table.json')
      .and_return(Dry::Monads::Success(stages_data))
  end

  it 'create annihilation stages' do
    service.call

    annihilation = Annihilation.first
    expect(annihilation).to have_attributes(
      name: 'The Grand Knight Territory Outskirts',
      game_id: 'camp_r_01'
    )
    expect(annihilation.stages.first).to have_attributes(
      code: 'The Grand Knight Territory Outskirts',
      zone: 4,
      game_id: 'camp_r_01'
    )
  end

  it 'does not create non-annihilation stages' do
    service.call

    expect(Stage.find_by(game_id: 'main_10-01')).not_to be_present
  end
end
