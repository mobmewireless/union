class FixForeignKeysInJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :project_id
    remove_column :jobs, :server_id
    add_column :jobs, :deployment_id, :string
    add_index :jobs, :deployment_id
  end
end
