FactoryBot.define do
  factory :clear do
    submitter factory: :user
    player factory: :user
    stage factory: :event_stage
    link { 'https://www.youtube.com/watch?v=0' }
  end
end
