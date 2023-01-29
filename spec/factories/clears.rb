FactoryBot.define do
  factory :clear do
    submitter factory: :user
    player factory: :user
    stage factory: :event_stage
  end
end
