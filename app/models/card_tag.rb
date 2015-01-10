class CardTag < ActiveRecord::Base
  belongs_to :card
  belongs_to :target, polymorphic: true
end
