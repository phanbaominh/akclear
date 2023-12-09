FactoryBot.define do
  factory :verification do
    verifier
    clear

    status { Verification::ACCEPTED }
  end
end
