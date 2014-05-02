FactoryGirl.define do
  sequence(:hostname) { |n| (Faker::Lorem.words(3) << n).join '-' }

  factory :server do
    hostname
  end
end
