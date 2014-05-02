class RenameColumnTypeOnCard < ActiveRecord::Migration
  def change
    rename_column :cards, :type, :label

  end
end
