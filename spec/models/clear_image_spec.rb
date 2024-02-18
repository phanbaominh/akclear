require 'rails_helper'

def generate_test_from_name(name, locale:)
  operator = Operator.find_by("name ILIKE '%#{name}%'")
  [operator.name(locale:), 0, 0, 0, operator.skill_game_ids, operator.rarity]
end

describe ClearImage do
  let(:log_data_path) { "tmp/clear_image_test/#{I18n.locale.to_s.underscore}/" }
  let(:clear_image) do
    FileUtils.rm_rf(log_data_path) if ClearImage::Logger.should_log?
    FileUtils.mkdir_p(log_data_path) if ClearImage::Logger.should_log?
    described_class.new(Pathname.new(image_path), possible_languages:, log_data_path:)
  end
  let(:possible_languages) { [I18n.locale] }

  after { ClearImage::Extracting::Reader.language = nil }

  # problem: ignore frequents words? case in point La Pluma turned into La Plum
  # reduce confidence threshold for group line? at least for english
  # choose name lines by most operator names?

  describe '#used_operators_data' do
    let(:received_result) do
      clear_image.used_operators_data.each do |data|
        data[:operator] = Operator.find(data[:operator_id])
      end
    end
    let(:get_expected_result) do
      operators.map do |(name, level, elite, skill, skill_game_ids, rarity)|
        operator = create(:operator, name:, skill_game_ids:, rarity:)
        {
          operator_id: operator.id,
          operator:,
          level:,
          elite:,
          skill:
        }
      end
    end

    context 'when language is english' do
      let(:possible_languages) { %w[en jp] }
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
        expect(received_result.size).to eq(get_expected_result.size + 1)
        expect(received_result).to include(*get_expected_result)
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
          ['カシャ', 60, 2, 1, ['skcom_atk_up[2]', 'skchr_cammou_2'], Operator::Rarifiable::FOUR_STARS], # correct elite: 1, s: 2
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
          expect(received_result.size).to eq(get_expected_result.size)
          expect(received_result).to include(*get_expected_result)
        end
      end
    end

    context 'when language is korean' do
      let(:operators) do
        # name, level, elite, skill, skill_game_ids
        [['머틀', 60, 2, 1, ['skcom_assist_cost[2]', 'skchr_myrtle_2'], 'four_stars'], # l: 1
         ['쏜즈', 20, 2, 2, ['skcom_atk_up[3]', 'skchr_thorns_2', 'skchr_thorns_3'], 'six_stars'], # s: 2
         ['사리아', 20, 2, 1, %w[skchr_demkni_1 skchr_demkni_2 skchr_demkni_3], 'six_stars'],
         ['혼', 1, 2, 1, %w[skchr_horn_1 skchr_horn_2 skchr_horn_3], 'six_stars'],
         ['프틸롭시스', 40, 2, 2, ['skcom_heal_up[3]', 'skchr_plosis_2'], 'five_stars'], # l: 1
         #  ['Lancet-2', 30, 0, nil, [], 'one_star'],
         ['수르트', 1, 0, 1, %w[skchr_surtr_1 skchr_surtr_2 skchr_surtr_3], 'six_stars'], # skill: 3, e: 0
         ['마운틴', 20, 2, 2, %w[skchr_f12yin_1 skchr_f12yin_2 skchr_f12yin_3], 'six_stars'],
         ['머드락', 1, 2, 2, ['skcom_def_up[3]', 'skchr_mudrok_2', 'skchr_mudrok_3'], 'six_stars'],
         #  ['굼', 60, 1, 1, %w[skchr_sunbr_1 skchr_sunbr_2], 'four_stars'],
         ['카디건', 55, 1, 1, ['skcom_heal_self[1]'], 'three_stars']]
      end

      let(:image_path) { 'spec/fixtures/images/ko_clear.jpg' }

      it 'returns correct attributes' do
        I18n.with_locale(:ko) do
          get_expected_result
          expect(received_result.size).to eq(get_expected_result.size)
          expect(received_result).to include(*get_expected_result)
        end
      end
    end

    context 'when language is simplified chinese' do
      let(:operators) do
        # name, level, elite, skill, skill_game_ids
        [['桃金娘', 40, 0, 1, ['skcom_assist_cost[2]', 'skchr_myrtle_2'], 'four_stars'], # l: 1, e : 2
         ['松果', 60, 2, 1, %w[skchr_pinecn_1 skchr_pinecn_2], 'four_stars'], # e: 1
         ['克洛丝', 55, 1, 1, ['skchr_kroos_1'], 'three_stars'],
         ['安赛尔', 55, 1, 1, ['skcom_range_extend'], 'three_stars'],
         ['巡林者', 30, 0, nil, [], 'two_stars'],
         ['嘉维尔', 60, 1, 1, %w[skchr_ccheal_1 skchr_ccheal_2], 'four_stars'],
         ['古米', 60, 2, 1, %w[skchr_sunbr_1 skchr_sunbr_2], 'four_stars'], # e: 1
         ['芬', 55, 1, 1, ['skcom_charge_cost[1]'], 'three_stars'],
         ['夜刀', 30, 0, nil, [], 'two_stars']]
      end

      let(:image_path) { 'spec/fixtures/images/cn_clear.jpg' }

      it 'returns correct attributes' do
        I18n.with_locale(:'zh-CN') do
          get_expected_result
          expect(received_result.size).to eq(get_expected_result.size)
          expect(received_result).to include(*get_expected_result)
        end
      end
    end
  end
end
