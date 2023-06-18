FactoryBot.define do
  factory :event do
    name { |n| "Event #{n}" }

    trait :latest do
      latest { true }
    end
  end
end
