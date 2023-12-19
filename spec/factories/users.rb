FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'Thisisavalidpassword1@' }
    username { Faker::Internet.username(specifier: 5..15) + rand(1000).to_s }

    factory :verifier do
      role { :verifier }
    end

    factory :admin do
      role { :admin }
    end
  end
end
