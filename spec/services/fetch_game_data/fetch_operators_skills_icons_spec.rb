require 'rails_helper'
require_relative './image_storable'

describe FetchGameData::FetchOperatorsSkillsIcons do
  let_it_be(:operator_with_multiple_skills) do
    create(:operator, skill_game_ids: %w[test_skchr_chyue_1 test_skchr_chyue_2])
  end
  let_it_be(:operator_with_one_skill) do
    create(:operator, skill_game_ids: ['test_skcom_heal_up[3]'])
  end
  let(:skill_data) do
    {
      'test_skchr_chyue_1' => {
        'iconId' => 'test_skchr_chyue_1'
      },
      'test_skchr_chyue_2' => {
        'iconId' => 'test_random'
      },
      'test_skcom_heal_up[3]' => {
        'iconId' => nil
      }
    }
  end
  let(:service) { described_class.new }

  before do
    allow(URI).to receive(:parse).and_return(double(open: 'image file'))
    allow(IO).to receive(:copy_stream)
    allow(FetchGameData::FetchJson)
      .to receive(:call)
      .and_return(Dry::Monads::Success(skill_data))
  end

  it 'stores images for existing episodes' do
    service.call

    expect(FetchGameData::FetchJson)
      .to have_received(:call)
      .with('https://raw.githubusercontent.com/Kengxxiao/ArknightsGameData_YoStar/main/en_US/gamedata/excel/skill_table.json')

    expect(URI).to have_received(:parse)
      .with('https://raw.githubusercontent.com/Aceship/Arknight-Images/main/skills/skill_icon_test_skchr_chyue_1.png')
    expect(URI).to have_received(:parse)
      .with('https://raw.githubusercontent.com/Aceship/Arknight-Images/main/skills/skill_icon_test_random.png')
    expect(URI).to have_received(:parse)
      .with('https://raw.githubusercontent.com/Aceship/Arknight-Images/main/skills/skill_icon_test_skcom_heal_up%5B3%5D.png')
    expect(URI).to have_received(:parse).exactly(3).times

    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/skills/test_skchr_chyue_1.png'))
    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/skills/test_skchr_chyue_2.png'))
    expect(IO)
      .to have_received(:copy_stream)
      .with('image file', Regexp.new('app/javascript/images/skills/test_skcom_heal_up\[3\].png'))
    expect(IO).to have_received(:copy_stream).exactly(3).times
  end

  include_examples 'image_storable' do
    let(:overwritten_image_name) { 'test_skchr_chyue_1' }
  end
end
