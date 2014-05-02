class IndexForeignKeysInProjectsServers < ActiveRecord::Migration
  def change
    add_index :projects_servers, :project_id
    add_index :projects_servers, :server_id
  end
end
