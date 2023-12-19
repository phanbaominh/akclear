FactoryBot.define do
  factory :stage, class: 'Stage' do
    transient do
      sequence(:base_game_id) { |i| "0-#{i}" }
    end

    game_id { base_game_id }
    stageable factory: :episode
    sequence(:code) { |i| "0-#{i}" }

    factory :event_stage do
      stageable factory: :event
    end

    Episode::Environment::ENVIRONMENTS.each do |environment|
      factory :"#{environment}_stage" do
        stageable factory: :episode

        transient do
          sequence(:base_game_id) { |i| "#{Episode::Environment.new(environment).to_game_id}_#{stageable.number}-#{i}" }
        end
      end
    end

    trait :challenge_mode do
      game_id { "#{base_game_id}#f#" }
    end
  end
end
