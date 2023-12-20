require 'rails_helper'

describe FetchGameData::FetchLatestEventsData do
  let(:latest_event) do
    {
      'id' => 'act20side',
      'displayType' => 'SIDESTORY',
      'name' => 'Ideal City: Carnival in the Endless Summer',
      'startTime' => 1_673_611_200,
      'endTime' => 1_675_421_999,
      'isReplicate' => false
    }
  end

  let(:ended_event) do
    {
      'id' => 'act18side',
      'displayType' => 'SIDESTORY',
      'name' => 'Lingering Echoes',
      'startTime' => 1_672_142_400,
      'endTime' => 1_675_421_999,
      'isReplicate' => false
    }
  end

  let(:record_restored_event) do
    {
      'id' => 'act11sre',
      'displayType' => 'BRANCHLINE',
      'name' => 'Under Tides - Rerun',
      'isReplicate' => false
    }
  end

  let(:ministory_event) do
    {
      'id' => 'act10mini',
      'displayType' => 'MINISTORY',
      'name' => 'A Light Spark in Darkness',
      'startTime' => 1_660_824_000,
      'endTime' => 1_675_421_999,
      'isReplicate' => false
    }
  end

  let(:rerun_event) do
    {
      'id' => 'act9sre',
      'displayType' => 'SIDESTORY',
      'name' => 'Who Is Real - Rerun',
      'isReplicate' => true,
      'endTime' => 1_628_852_399
    }
  end

  let(:original_event) do
    {
      'id' => 'act16d5',
      'displayType' => 'SIDESTORY',
      'name' => 'Who Is Real',
      'endTime' => 1_628_852_399
    }
  end

  let(:event_without_display_type) do
    {
      'id' => 'act21side',
      'name' => 'IL Siracusano',
      'endTime' => 1_675_421_999
    }
  end

  let(:events_data) do
    {
      'basicInfo' => {
        'act16d5' => original_event,
        'act21side' => event_without_display_type,
        'act20side' => latest_event,
        'act18side' => ended_event,
        'act11sre' => record_restored_event,
        'act10mini' => ministory_event,
        'act9sre' => rerun_event,
        'existing' => {
          'name' => 'Existing Event',
          'displayType' => 'MINISTORY',
          'endTime' => 1_675_421_999
        }
      }
    }
  end
  let!(:existing_event) { create(:event, game_id: 'existing') }
  let(:service) { described_class.new }

  before do
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/activity_table.json')
      .and_return(Dry::Monads::Success(events_data))
  end

  it 'creates events with correct attributes' do
    service.call

    expect(Event.find_by(game_id: 'act20side')).to have_attributes(
      name: 'Ideal City: Carnival in the Endless Summer',
      end_time: a_value_within(1.second).of(Time.zone.at(1_675_421_999))
    )
  end

  it 'creates events for activity with side/mini in id' do
    service.call

    expect(Event.find_by(game_id: 'act21side')).to be_present
  end

  it 'creates events for SIDESTORY activities' do
    service.call

    expect(Event.where(game_id: %w[act20side act18side]).distinct.count).to eq(2)
  end

  it 'create events for MINISTORY activities' do
    service.call

    expect(Event.find_by(game_id: 'act10mini')).to be_present
  end

  it 'updates existing events' do
    service.call

    expect(existing_event.reload).to have_attributes(name: 'Existing Event')
  end

  it 'does not create events for other activities or existing events' do
    service.call

    expect(Event.count).to eq(7)
    expect(Event.find_by(game_id: 'act11sre')).not_to be_present
  end

  it 'create events for rerun event' do
    service.call

    original_event_record = Event.find_by(game_id: original_event['id'])

    expect(Event.find_by(game_id: 'act9sre', original_event: original_event_record)).to be_present
  end

  context 'when json param is true' do
    let(:service) { described_class.new(json: true) }

    it 'returns correct json' do
      result = service.call.value!

      expect(result).to match(
        [
          { game_id: 'act16d5', name: 'Who Is Real' },
          { game_id: 'act21side', name: 'IL Siracusano' },
          { game_id: 'act20side', name: 'Ideal City: Carnival in the Endless Summer' },
          { game_id: 'act18side', name: 'Lingering Echoes' },
          { game_id: 'act10mini', name: 'A Light Spark in Darkness' },
          { game_id: 'act9sre', name: 'Who Is Real - Rerun' },
          { game_id: 'existing', name: 'Existing Event' }
        ]
      )
    end
  end
end
