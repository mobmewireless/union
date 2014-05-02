class IndexJobIdInJobLogs < ActiveRecord::Migration
  def change
    add_index :job_logs, :job_id
  end
end
