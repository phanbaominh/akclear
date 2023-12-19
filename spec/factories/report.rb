FactoryBot.define do
  factory :report do
    reporter factory: :user
    clear
  end
end
