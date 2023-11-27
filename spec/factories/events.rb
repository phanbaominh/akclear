FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "Event #{n}" }

    trait :latest do
      latest { true }
    end
  end
end
