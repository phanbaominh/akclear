FactoryBot.define do
  factory :risk_conflict_relation do
    risk
    conflicted_risk factory: :risk
    kind { 1 }
  end
end
