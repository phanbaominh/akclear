FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'Thisisavalidpassword1@' }

    factory :verifier do
      role { :verifier }
    end

    factory :admin do
      role { :admin }
    end
  end
end
