class ChangeColumnsArchivedAndTimeSpentInCards < ActiveRecord::Migration
  def up
    change_column :cards, :archived, :boolean, default: false
    change_column :cards, :time_spent, :integer, default: 0
  end

  def down
    change_column :cards, :archived, :boolean, default: nil
    change_column :cards, :time_spent, :integer, default: nil
  end
end
