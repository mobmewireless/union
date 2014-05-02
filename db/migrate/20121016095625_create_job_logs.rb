class CreateJobLogs < ActiveRecord::Migration
  def change
    create_table :job_logs do |t|
      t.integer :job_id
      t.integer :level
      t.text :log

      t.timestamps
    end
  end
end
