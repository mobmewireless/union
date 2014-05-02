FactoryGirl.define do
  sequence(:timestamp) { rand((Time.now - 1.day)..Time.now).to_f.to_s }

  factory :server_log do
    timestamp
    log Faker::Lorem.sentences
  end
end
