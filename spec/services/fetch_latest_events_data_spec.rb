require 'rails_helper'

describe FetchLatestEventsData do
  let(:latest_event) do
    {
      'id' => 'act20side',
      'displayType' => 'SIDESTORY',
      'name' => 'Ideal City: Carnival in the Endless Summer',
      'startTime' => 1_673_611_200,
      'isReplicate' => false
    }
  end

  let(:ended_event) do
    {
      'id' => 'act18side',
      'displayType' => 'SIDESTORY',
      'name' => 'Lingering Echoes',
      'startTime' => 1_672_142_400,
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
      'isReplicate' => false
    }
  end

  let(:rerun_event) do
    {
      'id' => 'act9sre',
      'displayType' => 'SIDESTORY',
      'name' => 'Who Is Real - Rerun',
      'isReplicate' => true
    }
  end

  let(:events_data) do
    {
      'basicInfo' => {
        'act20side' => latest_event,
        'act18side' => ended_event,
        'act11sre' => record_restored_event,
        'act10mini' => ministory_event,
        'act9sre' => rerun_event,
        'existing' => {
          name: 'Existing Event'
        }
      }
    }
  end

  let!(:current_latest_event) { create(:event, :latest, game_id: 'existing') }
  let(:service) { described_class.new }

  before do
    allow(FetchJson)
      .to receive(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/activity_table.json')
      .and_return(Dry::Monads::Success(events_data))
  end

  describe 'creating events' do
    it 'creates events with correct attributes' do
      service.call

      expect(Event.find_by(game_id: 'act20side')).to have_attributes(
        name: 'Ideal City: Carnival in the Endless Summer'
      )
    end

    it 'creates events for SIDESTORY activities' do
      service.call

      expect(Event.where(game_id: %w[act20side act18side]).distinct.count).to eq(2)
    end

    it 'marks first SIDESTORY activity as latest event' do
      service.call

      expect(Event.find_by(game_id: 'act20side')).to be_latest
    end

    it 'unmark current latest event' do
      service.call

      expect(current_latest_event.reload).not_to be_latest
    end

    it 'create events for MINISTORY activities' do
      service.call

      expect(Event.find_by(game_id: 'act10mini')).to be_present
    end

    it 'does not create events for other activities or existing events' do
      service.call

      expect(Event.count).to eq(4)
      expect(Event.find_by(game_id: 'act11sre')).not_to be_present
    end

    it 'does not create events for rerun event' do
      service.call

      expect(Event.find_by(game_id: 'act9sre')).not_to be_present
    end
  end
end
