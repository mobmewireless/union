FactoryGirl.define do
  sequence(:trello_id) { SecureRandom.hex(12) }
  sequence(:short_link) { SecureRandom.hex(4) }
  sequence(:trello_list_id) { SecureRandom.hex(12) }

  factory :card do
    trello_id
    trello_list_id
    board
    data {
      {
        card: {
          shortLink: generate(:short_link),
          name: Faker::Lorem.sentence(5),
          id: generate(:trello_id)
        },
        creator: {
          id: generate(:trello_id),
          avatarHash: generate(:trello_id),
          fullName: Faker::Name.name,
          initials: Faker::Lorem.characters(2).upcase,
          username: Faker::Lorem.word
        }
      }.with_indifferent_access
    }
  end
end
