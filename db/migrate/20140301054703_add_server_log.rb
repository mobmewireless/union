class AddServerLog < ActiveRecord::Migration
  def change
    create_table :server_logs do |t|
      t.belongs_to :server
      t.datetime :timestamp
      t.text  :log
      t.timestamps
    end
  end
end
