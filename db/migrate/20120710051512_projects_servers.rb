class ProjectsServers < ActiveRecord::Migration
  def up
  	create_table "projects_servers", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "server_id"
  end

  end

  def down
  end
end
