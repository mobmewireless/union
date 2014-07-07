FactoryGirl.define do
  sequence(:email) { |n| Faker::Internet.email }

  factory :user do
    email
    password 'password'
  end
end
