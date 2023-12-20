require 'rails_helper'

describe FetchGameData::FetchLatestOperatorsData do
  let(:file_content) do
    {
      char_102_texas: {
        'name' => 'Texas', 'rarity' => 'TIER_5',
        'skills' => [{ 'skillId' => 'skchr_texas_1' }, { 'skillId' => 'skchr_texas_2' }]
      },
      token_10000_silent_healrb: { 'name' => 'Medic Drone', 'subProfessionId' => 'notchar1', 'skills' => [] },
      token_10007_phatom_twin: { 'name' => 'Phantom in the Mirror', 'profession' => 'TOKEN' },
      char_513_apionr: { 'name' => 'Tulip', 'isNotObtainable' => true }
    }
  end
  let(:skill_data) do
    {
      'skchr_texas_1' => {
        'iconId' => 'skchr_texas_1_icon'
      },
      'skchr_texas_2' => {
        'iconId' => nil
      }
    }
  end
  let(:service) { described_class.new }

  before do
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/character_table.json')
      .and_return(Dry::Monads::Success(file_content))
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/skill_table.json')
      .and_return(Dry::Monads::Success(skill_data))
  end

  context 'deleting_invalid param' do
    let!(:invalid_operator) do
      create(:operator, game_id: 'token_10000_silent_healrb', name: 'Medic Drone')
    end
    let!(:invalid_used_operator) do
      create(:used_operator, operator: invalid_operator)
    end

    context 'when destroy_invalid is true' do
      let(:service) { described_class.new(destroy_invalid: true) }

      it 'deletes invalid operators' do
        service.call

        expect(Operator.find_by(game_id: 'token_10000_silent_healrb')).not_to be_present
        expect(UsedOperator.find_by(operator: invalid_operator)).not_to be_present
      end
    end

    context 'when destroy_invalid is false' do
      it 'does not delete invalid operators' do
        service.call

        expect(Operator.find_by(game_id: 'token_10000_silent_healrb')).to be_present
        expect(UsedOperator.find_by(operator: invalid_operator)).to be_present
      end
    end
  end

  it 'creates operator correctly' do
    expect { service.call }.to change(Operator, :count).from(0).to(1)
    expect(
      Operator.i18n.find_by(
        name: 'Texas', game_id: 'char_102_texas', rarity: 4,
        skill_game_ids: %w[skchr_texas_1 skchr_texas_2],
        skill_icon_ids: %w[skchr_texas_1_icon skchr_texas_2]
      )
    ).to be_present
  end

  it 'fetches from correct link' do
    service.call
    expect(FetchGameData::FetchJson)
      .to have_received(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/character_table.json')
  end

  it 'does not create notchar operator' do
    service.call

    expect(Operator.find_by(game_id: 'token_10000_silent_healrb')).not_to be_present
  end

  context 'when locale is jp' do
    before do
      allow(FetchGameData::FetchJson)
        .to receive(:call)
        .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/ja_JP/gamedata/excel/character_table.json')
        .and_return(Dry::Monads::Success(file_content))
    end

    it 'fetches from correct link' do
      I18n.with_locale(:jp) { service.call }
      expect(FetchGameData::FetchJson)
        .to have_received(:call)
        .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/ja_JP/gamedata/excel/character_table.json')
    end

    it 'creates operator correctly' do
      I18n.with_locale(:jp) do
        service.call
        expect(operator =
                 Operator.i18n.find_by(
                   name: 'Texas', game_id: 'char_102_texas', rarity: 4,
                   skill_game_ids: %w[skchr_texas_1 skchr_texas_2],
                   skill_icon_ids: %w[skchr_texas_1_icon skchr_texas_2]
                 )).to be_present
        expect(operator.name).to eq('Texas')
        expect(operator.name(locale: :en)).to eq(nil)
      end
    end
  end
end
