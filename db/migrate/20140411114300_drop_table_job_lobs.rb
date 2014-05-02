class DropTableJobLobs < ActiveRecord::Migration
  def change
    drop_table :job_logs
  end
end
