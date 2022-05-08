FactoryBot.define do
  factory :risk do
    description { "A risk" }
    icon { "icon.png" }
    level { 1 }
    contingency_contract
  end
end
