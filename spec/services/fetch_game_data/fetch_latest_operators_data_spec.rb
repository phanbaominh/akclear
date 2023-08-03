require 'rails_helper'

describe FetchGameData::FetchLatestOperatorsData do
  let(:file_content) do
    {
      "char_102_texas": {
        'name' => 'Texas', 'rarity' => 4, 'subProfessionId' => 'pioneer',
        'skills' => [{ 'skillId' => 'skchr_texas_1' }, { 'skillId' => 'skchr_texas_2' }]
      },
      'token_10000_silent_healrb': { 'name' => 'Medic Drone', 'subProfessionId' => 'notchar1', 'skills' => [] }
    }
  end
  let(:service) { described_class.new }

  before do
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .and_return(Dry::Monads::Success(file_content))
  end

  it 'creates operator correctly' do
    expect { service.call }.to change(Operator, :count).from(0).to(1)
    expect(Operator.i18n.find_by(name: 'Texas', game_id: 'char_102_texas', rarity: 4,
                                 skill_game_ids: %w[skchr_texas_1 skchr_texas_2])).to be_present
  end

  it 'fetches from correct link' do
    service.call
    expect(FetchGameData::FetchJson)
      .to have_received(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/en_US/gamedata/excel/character_table.json')
  end

  it 'does not create notchar operator' do
    service.call

    expect(Operator.find_by(game_id: 'token_10000_silent_healrb')).not_to be_present
  end

  context 'when locale is jp' do
    it 'fetches from correct link' do
      I18n.with_locale(:jp) { service.call }
      expect(FetchGameData::FetchJson)
        .to have_received(:call)
        .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData/master/ja_JP/gamedata/excel/character_table.json')
    end

    it 'creates operator correctly' do
      I18n.with_locale(:jp) do
        service.call
        expect(operator = Operator.i18n.find_by(name: 'Texas', game_id: 'char_102_texas', rarity: 4,
                                                skill_game_ids: %w[skchr_texas_1 skchr_texas_2])).to be_present
        expect(operator.name).to eq('Texas')
        expect(operator.name(locale: :en)).to eq(nil)
      end
    end
  end
end
