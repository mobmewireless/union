class AddTypeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :type, :integer
  end
end
