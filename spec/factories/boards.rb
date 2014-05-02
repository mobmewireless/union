# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :board do
    trello_board_id { generate :trello_id }
    name { Faker::Lorem.words(2).join ' ' }
    short_url { Faker::Internet.url }
  end
end
