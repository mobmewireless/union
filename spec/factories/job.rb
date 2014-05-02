FactoryGirl.define do
  factory :job do
    status Job::STATUS_QUEUED
    requested_by { Faker::Internet.email }
    authorized_by { Faker::Internet.email }
    deployment
    project
    job_type Job::TYPE_DEPLOY
  end
end
