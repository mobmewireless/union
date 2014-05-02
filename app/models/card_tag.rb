class CardTag < ActiveRecord::Base
  attr_accessible :card_id, :target_id, :target_type

  belongs_to :card
  belongs_to :target, polymorphic: true
end
