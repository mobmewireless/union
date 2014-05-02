class CreateCardTags < ActiveRecord::Migration
  def change
    create_table :card_tags do |t|
      t.integer :card_id
      t.integer :target_id
      t.string :target_type

      t.timestamps
    end

    add_index :card_tags, %w(target_id target_type)
  end
end
