FactoryBot.define do
  factory :event_stage, class: 'Stage' do
    stageable factory: :event
  end
end
