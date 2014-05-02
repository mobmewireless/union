class ChangeDeletedInCardAddDefault < ActiveRecord::Migration
  def up
    change_column :cards, :deleted, :boolean, default: false
  end

  def down
    change_column :cards, :deleted, :boolean, default: nil
  end
end
