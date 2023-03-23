FactoryBot.define do
  factory :event do
    trait :latest do
      latest { true }
    end
  end
end
