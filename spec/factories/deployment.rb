FactoryGirl.define do
  sequence(:deployment_path) { |n| "/home/login_user/deploy/#{Faker::Lorem.words(3).join('_')}_#{n}" }

  factory :deployment do
    server
    project
    login_user 'deploy'
    port 22
    deployment_path
    deployment_name { Faker::Lorem.words(3).join('_') }
  end
end
