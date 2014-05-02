class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.integer :server_id
      t.integer :project_id
      t.string :login_user
      t.integer :port
      t.string :deployment_path

      t.timestamps
    end
  end
end
