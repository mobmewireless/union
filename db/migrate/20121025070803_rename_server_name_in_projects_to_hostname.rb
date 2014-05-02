class RenameServerNameInProjectsToHostname < ActiveRecord::Migration
  def change
    rename_column :servers, :server_name, :hostname
    add_index :servers, :hostname, unique: true
  end
end
