require 'rails_helper'

describe Operator::Rarifiable do
  describe '#rarity' do
    subject { build(:operator) }

    it {
      is_expected.to define_enum_for(:rarity).with_values(%w[one_star two_stars three_stars four_stars five_stars
                                                             six_stars])
    }
  end

  describe '#max_elite' do
    it 'returns the max elite for the operator\'s rarity' do
      [0, 0, 1, 2, 2, 2].each_with_index do |max_elite, rarity|
        expect(build_stubbed(:operator, rarity:).max_elite).to eq(max_elite)
      end
    end
  end

  describe '#max_skill' do
    context 'when elite is 1' do
      it 'returns the min number of skills for the operator\'s rarity' do
        [0, 0, 1, 2, 2, 2].each_with_index do |max_skill, rarity|
          expect(build_stubbed(:operator, rarity:).max_skill(elite: 1)).to eq(max_skill)
        end
      end

      context 'when the operator has a unique skill_game_ids' do
        it 'returns the number of skills based on the skill_game_ids' do
          operator_sharp = build_stubbed(:operator, rarity: 'five_stars', skill_game_ids: ['skchr_aguard_1'])
          expect(operator_sharp.max_skill(elite: 1)).to eq(1)
        end
      end
    end

    context 'when elite is 2' do
      it 'returns the number of skill game ids of operator' do
        [1, 2, 3].each do |number_of_skill_game_ids|
          expect(build_stubbed(:operator, skill_game_ids: Array.new(number_of_skill_game_ids))
            .max_skill(elite: 2))
            .to eq(number_of_skill_game_ids)
        end
      end
    end
  end

  describe '#max_level' do
    {
      0 => [30],
      1 => [30],
      2 => [40, 55],
      3 => [45, 60, 70],
      4 => [50, 70, 80],
      5 => [50, 80, 90]
    }.each do |rarity, max_levels|
      max_levels.each_with_index do |max_level, elite|
        it "returns the max level #{max_level} for the operator with rarity #{rarity} and elite #{elite}" do
          expect(build_stubbed(:operator, rarity:).max_level(elite:)).to eq(max_level)
        end
      end
    end
  end

  describe '#max_skill_level' do
    {
      0 => [0],
      1 => [0],
      2 => [4, 7],
      3 => [4, 7, 7],
      4 => [4, 7, 7],
      5 => [4, 7, 7]
    }.each do |rarity, max_skill_levels|
      max_skill_levels.each_with_index do |max_skill_level, elite|
        it "returns the max skil level #{max_skill_level} for the operator with rarity #{rarity} and elite #{elite}" do
          expect(build_stubbed(:operator, rarity:).max_skill_level(elite:)).to eq(max_skill_level)
        end
      end
    end
  end
end
