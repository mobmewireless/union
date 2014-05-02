class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :project_name
      t.text :git_url
      t.text :cached_directory
      t.string :branch

      t.timestamps
    end
  end
end
