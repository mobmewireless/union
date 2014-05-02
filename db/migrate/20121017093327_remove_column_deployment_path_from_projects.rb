class RemoveColumnDeploymentPathFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :deployment_path
  end
end
