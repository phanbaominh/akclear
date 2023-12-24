require 'rails_helper'
require 'dry/monads'

describe FetchGameData::FetchLatestStagesData do
  let(:story_stage) do
    {
      'isStoryOnly' => true,
      'stageId' => 'act20side_st01',
      'code' => 'IC-ST-1'
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

  let(:hard_episode_stage) do
    {
      'stageType' => 'SUB',
      'zoneId' => 'main_10',
      'code' => 'H10-1',
      'isStoryOnly' => false,
      'stageId' => 'hard_10-01'
    }
  end

  let(:event_stage) do
    {
      'stageType' => 'ACTIVITY',
      'zoneId' => 'act20side_zone2',
      'code' => 'IC-EX-1',
      'isStoryOnly' => false,
      'stageId' => 'act20side_ex01'
    }
  end

  let(:stage_for_non_existing_stageable) do
    {
      'stageType' => 'ACTIVITY',
      'zoneId' => 'act18side_zone2',
      'code' => 'LE-EX-1',
      'isStoryOnly' => false,
      'stageId' => 'act18side_ex01'
    }
  end

  let(:episode_tutorial_stage) do
    {
      'code' => 'TR-20',
      'stageId' => 'tr_20',
      'stageType' => 'MAIN',
      'zoneId' => 'main_10',
    }
  end
  let(:stages_data) do
    {
      'stages' => {
        'main_10-01' => episode_stage,
        'hard_10-01' => hard_episode_stage,
        'act20side_ex01' => event_stage,
        'act20side_st01' => story_stage,
        'act20side_tr01' => { 'stageId' => 'act20side_tr01', 'code' => 'IC-TR-1' },
        'tr_20' => episode_tutorial_stage,
        'act18side_ex01' => stage_for_non_existing_stageable
      }
    }
  end

  let!(:episode) { create(:episode, game_id: 'main_10') }
  let!(:event) { create(:event, game_id: 'act20side') }
  let(:service) { described_class.new }

  before do
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/stage_table.json')
      .and_return(Dry::Monads::Success(stages_data))
  end

  it 'create stages for existing episode' do
    service.call

    expect(episode.stages.first).to have_attributes(
      code: '10-1',
      game_id: 'main_10-01',
      zone: 1
    )
    expect(episode.stages.second).to have_attributes(
      code: 'H10-1',
      game_id: 'hard_10-01',
      zone: 1
    )
  end

  it 'create stages for existing event' do
    service.call

    expect(event.stages.first).to have_attributes(
      code: 'IC-EX-1',
      game_id: 'act20side_ex01',
      zone: 2
    )
  end

  it 'create tutorial stages' do
    service.call

    expect(Stage.find_by(game_id: 'tr_20')).to be_present
  end

  it 'does not create story stages' do
    service.call

    expect(Stage.find_by(game_id: 'act18side_st01')).not_to be_present
  end

  it 'does not create stages for non-existing stageable' do
    service.call

    expect(Stage.count).to eq(4)
    expect(Stage.find_by(game_id: '')).not_to be_present
  end
end
