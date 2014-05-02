class RenameTypeFieldInJobsTableToJobsType < ActiveRecord::Migration
  def up
    rename_column :jobs, :type, :job_type
  end

  def down
    rename_column :jobs, :job_type, :type
  end
end
