FactoryBot.define do
  factory :operator do
    sequence(:name) { |i| "Operator_#{i}" }
    rarity { Operator::FIVE_STARS }
    transient do
      skill_number { 0 }
    end
    skill_game_ids { Array.new(skill_number) { |i| "skchr_aglina_#{i + 1}" } }
  end
end
