require 'rails_helper'

describe FetchGameData::FetchLatestOperatorsData do
  let(:file_content) { { "char_102_texas": { 'name' => 'Texas' } } }
  let(:service) { described_class.new }

  before do
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .and_return(Dry::Monads::Success(file_content))
  end

  it 'creates operator correctly' do
    expect { service.call }.to change(Operator, :count).from(0).to(1)
    expect(Operator.find_by(name: 'Texas', game_id: 'char_102_texas')).to be_present
  end

  it 'fetches from correct link' do
    service.call
    expect(FetchGameData::FetchJson)
      .to have_received(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/character_table.json')
  end
end
