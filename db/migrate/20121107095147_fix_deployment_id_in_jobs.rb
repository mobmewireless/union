class FixDeploymentIdInJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :deployment_id
    add_column :jobs, :deployment_id, :integer
    add_index :jobs, :deployment_id
  end
end
