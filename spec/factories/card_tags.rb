# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card_tag do
    card_id 1
    target_id 1
    target_type "MyString"
  end
end
