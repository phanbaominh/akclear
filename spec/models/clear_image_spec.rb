require 'rails_helper'

def generate_test_from_name(name, locale:)
  operator = Operator.find_by("name ILIKE '%#{name}%'")
  [operator.name(locale:), operator.skill_game_ids, operator.rarity]
end

describe ClearImage do
  let(:clear_image) { described_class.new(Pathname.new(image_path), Rails.root.join('tmp'), {}) }

  # problem: ignore frequents words? case in point La Pluma turned into La Plum
  # reduce confidence threshold for group line? at least for english
  # choose name lines by most operator names?

  describe '#used_operators_data' do
    let(:received_result) { clear_image.used_operators_data }
    let(:get_expected_result) do
      operators.map do |(name, level, elite, skill, skill_game_ids, rarity)|
        {
          operator_id: create(:operator, name:, skill_game_ids:, rarity:).id,
          level:,
          elite:,
          skill:
        }
      end
    end

    context 'when language is english' do
      let(:operators) do
        [
          # name, level, elite, skill, skill_game_ids
          ['Melantha', 55, 1, 1, ['skcom_atk_up[1]'], Operator::Rarifiable::THREE_STARS],
          ['Myrtle', 45, 2, 1, ['skcom_assist_cost[2]', 'skchr_myrtle_2'], Operator::Rarifiable::FOUR_STARS],
          ['La Pluma', 50, 2, 2, %w[skchr_crow_1 skchr_crow_2], Operator::Rarifiable::FIVE_STARS],
          ['Kafka', 1, 0, 1, %w[skchr_kafka_1 skchr_kafka_2], Operator::Rarifiable::FIVE_STARS],
          ['Chongyue', 80, 1, 1, %w[skchr_chyue_1 skchr_chyue_2 skchr_chyue_3], Operator::Rarifiable::SIX_STARS],
          ['Noir Corne', 30, 0, nil, [], Operator::Rarifiable::TWO_STARS],
          ['Arene', 60, 1, 1, %w[skchr_spikes_1 skchr_spikes_2], Operator::Rarifiable::FOUR_STARS],
          ['Zima', 45, 2, 1, ['skcom_charge_cost[3]', 'skchr_headbr_2'], Operator::Rarifiable::FIVE_STARS], # real elite is 1
          ['Bagpipe', 60, 2, 3, ['skcom_quickattack[3]', 'skchr_bpipe_2', 'skchr_bpipe_3'],
           Operator::Rarifiable::SIX_STARS],
          ['THRM-EX', 30, 0, nil, [], Operator::Rarifiable::ONE_STAR]
        ]
      end
      let(:image_path) { 'spec/fixtures/images/english_clear.jpg' }

      it 'returns correct attributes' do
        get_expected_result
        expect(received_result).to match_array(get_expected_result)
        # expect(received_result).to match_array(get_expected_result)
      end
    end

    context 'when language is japanese' do
      let(:operators) do
        [
          # name, level, elite, skill, skill_game_ids
          ['ムリナール', 90, 2, 3, %w[skchr_mlynar_1 skchr_mlynar_2 skchr_mlynar_3], Operator::Rarifiable::SIX_STARS],
          ['カタパルト', 55, 1, 1, ['skchr_catap_1'], Operator::Rarifiable::THREE_STARS],
          ['ラヴァ', 55, 1, 1, ['skcom_magic_rage[1]'], Operator::Rarifiable::THREE_STARS],
          ['ミッドナイト', 55, 1, 1, ['skchr_midn_1'], Operator::Rarifiable::THREE_STARS],
          ['プリュム', 55, 1, 1, ['skcom_quickattack[1]'], Operator::Rarifiable::THREE_STARS],
          ['カシャ', 60, 2, 2, ['skcom_atk_up[2]', 'skchr_cammou_2'], Operator::Rarifiable::FOUR_STARS], # correct elite: 1
          ['ハイビスカス', 55, 1, 1, ['skcom_heal_up[1]'], Operator::Rarifiable::THREE_STARS],
          ['クルース', 55, 1, 1, ['skchr_kroos_1'], Operator::Rarifiable::THREE_STARS],
          ['カーディ', 55, 1, 1, ['skcom_heal_self[1]'], Operator::Rarifiable::THREE_STARS],
          ['メランサ', 55, 1, 1, %w[skcom_atk_up[1]], Operator::Rarifiable::THREE_STARS],
          ['フェン', 55, 1, 1, ['skcom_charge_cost[1]'], Operator::Rarifiable::THREE_STARS]
        ]
      end
      let(:image_path) { 'spec/fixtures/images/jp_clear.jpg' }

      it 'returns correct attributes' do
        I18n.with_locale(:jp) do
          get_expected_result
          expect(received_result).to match_array(get_expected_result)
        end
      end
    end
  end
end
