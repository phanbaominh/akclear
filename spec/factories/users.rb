FactoryBot.define do
  factory :user do
    sequence(:username) { |i| "Username_#{i}" }
    sequence(:email) { |i| "Email_#{i}" }
    password { "gamegame1" }
  end
end
