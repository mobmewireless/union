class AddDeletedToCard < ActiveRecord::Migration
  def change
    add_column :cards, :deleted, :boolean
    add_index :cards, :deleted
  end
end
