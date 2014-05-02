class AddDeploymentPathToProject < ActiveRecord::Migration
  def change
    add_column :projects, :deployment_path, :string

  end
end
