class AddIndexToCardTagsUniqueAssociation < ActiveRecord::Migration
  def change
    add_index :card_tags, %w(card_id target_id target_type), unique: true
  end
end
