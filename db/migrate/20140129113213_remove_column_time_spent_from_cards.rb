class RemoveColumnTimeSpentFromCards < ActiveRecord::Migration
  def change
    remove_column :cards, :time_spent
  end
end
