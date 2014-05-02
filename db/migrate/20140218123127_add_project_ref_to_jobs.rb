class AddProjectRefToJobs < ActiveRecord::Migration
  def change
    add_reference :jobs, :project, index: true
  end
end
