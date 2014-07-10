FactoryGirl.define do
  sequence(:email) { |n| "#{Faker::Name.first_name}.n@example.org"}

  factory :user do
    email
    password 'password'
  end
end
