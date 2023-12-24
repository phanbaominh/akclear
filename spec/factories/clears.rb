FactoryBot.define do
  factory :clear do
    submitter factory: :user
    channel
    sequence(:link) { |i| "https://www.youtube.com/watch?v=#{i}" }
    transient do
      sequence(:code) { |i| "0-#{i}" }
    end
    stage { association :event_stage, code: }

    trait :rejected do
      after(:create) do |clear|
        if clear.verification
          clear.verification.update(status: Verification::REJECTED)
        else
          create(:verification, status: Verification::REJECTED, clear:)
        end
      end
    end

    trait :verified do
      after(:create) do |clear|
        create(:verification, clear:)
      end
    end

    trait :reported do
      after(:create) do |clear|
        create(:report, clear:)
      end
    end
  end
end
