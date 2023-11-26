FactoryBot.define do
  factory :clear do
    submitter factory: :user
    channel
    stage factory: :event_stage
    link { 'https://www.youtube.com/watch?v=0' }

    trait :declined do
      after(:create) do |clear|
        create(:verification, status: Verification::DECLINED, clear:)
      end
    end
  end
end
