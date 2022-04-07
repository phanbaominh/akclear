FactoryBot.define do
  factory :video do
    link { "youtube.com" }
    description { "description" }
    like { 1 }
    user
  end
end
