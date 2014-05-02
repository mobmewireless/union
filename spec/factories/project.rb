FactoryGirl.define do
  sequence(:project_name) { |n| Faker::Lorem.words(3).join('-') + "-#{n}" }

  factory :project do
    project_name
    git_url "git@git.testcompany.com:#{Faker::Lorem.word}/#{Faker::Lorem.words(2).join('-')}.git"
    branch 'master'
  end
end
