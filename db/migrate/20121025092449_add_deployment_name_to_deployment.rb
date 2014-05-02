class AddDeploymentNameToDeployment < ActiveRecord::Migration
  def change
    add_column :deployments, :deployment_name, :string
    add_index :deployments, :deployment_name
  end
end
