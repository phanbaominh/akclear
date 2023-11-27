FactoryBot.define do
  factory :stage, class: 'Stage' do
    stageable factory: :episode
    sequence(:code) { |i| "0-#{i}" }

    factory :event_stage do
      stageable factory: :event
    end
  end
end
