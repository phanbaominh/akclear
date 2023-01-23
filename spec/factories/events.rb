FactoryBot.define do
  factory :event do
    latest { false }

    trait :latest do
      latest { true }
    end
  end
end
