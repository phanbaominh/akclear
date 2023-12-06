FactoryBot.define do
  factory :episode do
    number { 1 }
    game_id { "main_#{number}" }
  end
end
