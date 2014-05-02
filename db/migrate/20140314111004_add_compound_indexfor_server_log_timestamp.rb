class AddCompoundIndexforServerLogTimestamp < ActiveRecord::Migration
  def change
    add_index :server_logs, [:server_id, :timestamp], unique: true
  end
end
