FactoryBot.define do
  factory :channel do
    user { nil }
    sequence(:external_id) { |i| "abc#{i}" }
  end
end
