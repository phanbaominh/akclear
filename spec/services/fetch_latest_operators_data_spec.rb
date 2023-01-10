require 'rails_helper'

describe FetchLatestOperatorsData do
  let(:file_double) { double(read: file_content) }
  let(:file_content) { { "char_102_texas": { 'name' => 'Texas' } }.to_json }
  let(:service) { described_class.new }

  before do
    allow(URI)
      .to receive(:parse)
      .and_return(instance_double(URI::HTTPS, open: file_double))
  end

  it 'creates operator correctly' do
    expect { service.call }.to change(Operator, :count).from(0).to(1)
    expect(Operator.find_by(name: 'Texas', game_id: 'char_102_texas')).to be_present
  end

  it 'fetches from correct link' do
    service.call
    expect(URI)
      .to have_received(:parse)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/character_table.json')
  end
end
