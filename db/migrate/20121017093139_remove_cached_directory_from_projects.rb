class RemoveCachedDirectoryFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :cached_directory
  end
end
