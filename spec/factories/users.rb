FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'Thisisavalidpassword1@' }
  end
end
