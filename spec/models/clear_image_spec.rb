require 'rails_helper'

describe ClearImage do
  let(:clear_image) { described_class.new(image_path) }

  describe '#used_operators_data' do
    let(:received_result) { clear_image.used_operators_data }
    let(:get_expected_result) do
      operators.map do |(name, level, elite, skill, skill_game_ids, rarity)|
        {
          operator: create(:operator, name:, skill_game_ids:, rarity:),
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
          ['Zima', 45, 1, 1, ['skcom_charge_cost[3]', 'skchr_headbr_2'], Operator::Rarifiable::FIVE_STARS],
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
          ['クルース', 55, 1, 1, ['skchr_kroos_1'], Operator::Rarifiable::THREE_STARS],
          ['ポプカル', 55, 1, 1, ['skcom_atk_up[1]'], Operator::Rarifiable::THREE_STARS],
          ['アンセル', 55, 1, 1, ['skcom_range_extend'], Operator::Rarifiable::THREE_STARS],
          ['カーディ', 55, 1, 1, ['skcom_heal_self[1]'], Operator::Rarifiable::THREE_STARS],
          ['テンニンカ', 3, 0, 1, ['skcom_assist_cost[2]', 'skchr_myrtle_2'], Operator::Rarifiable::FOUR_STARS], # correct level: 30, elite: 2
          ['プリュム', 55, 1, 1, ['skcom_quickattack[1]'], Operator::Rarifiable::THREE_STARS],
          ['ハイビスカス', 5, 0, 1, ['skcom_heal_up[1]'], Operator::Rarifiable::THREE_STARS], #  correct elite: 1, level: 55
          ['ジェシカ', 60, 1, 1, %w[skchr_jesica_1 skchr_jesica_2], Operator::Rarifiable::FOUR_STARS],
          ['グラベル', 30, 2, 2, %w[skchr_gravel_1 skchr_gravel_2], Operator::Rarifiable::FOUR_STARS],
          ['ケルシー', 90, 2, 3, %w[skchr_kalts_1 skchr_kalts_2 skchr_kalts_3], Operator::Rarifiable::SIX_STARS]
        ]
      end
      let(:image_path) { 'spec/fixtures/images/jp_clear.png' }

      it 'returns correct attributes' do
        I18n.with_locale(:jp) { get_expected_result }
        expect(received_result).to match_array(get_expected_result)
      end
    end
  end
end