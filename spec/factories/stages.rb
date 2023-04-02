FactoryBot.define do
  factory :stage, class: 'Stage' do
    stageable factory: :episode

    factory :event_stage do
      stageable factory: :event
    end
  end
end
