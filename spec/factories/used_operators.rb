FactoryBot.define do
  factory :used_operator do
    operator
    clear
    factory :full_used_operator do
      level { rand(1..40) }
      skill { rand(1..2) }
      skill_level { rand(1..7) }
      elite { rand(1..2) }
      operator do
        association :operator, rarity: [Operator::FOUR_STARS, Operator::FIVE_STARS, Operator::SIX_STARS].sample,
                               skill_game_ids: %w[1 2]
      end
    end
  end
end
