class AddIndexToDeployments < ActiveRecord::Migration
  def change
    add_index :deployments, :server_id
    add_index :deployments, :project_id
  end
end
