FactoryBot.define do
  factory :operator do
    name { |i| "Operator_#{i}" }
    rarity { Operator::FIVE_STARS }
  end
end
