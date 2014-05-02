class ChangeServerLogTimeStampTypeToString < ActiveRecord::Migration
  def change
    change_table :server_logs do |t|
      t.change :timestamp, :string
    end
  end
end
