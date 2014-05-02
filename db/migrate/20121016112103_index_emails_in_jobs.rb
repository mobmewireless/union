class IndexEmailsInJobs < ActiveRecord::Migration
  def change
    add_index :jobs, :requested_by
    add_index :jobs, :authorized_by
  end
end
