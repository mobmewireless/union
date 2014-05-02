class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :status
      t.integer :project_id
      t.integer :server_id
      t.string :requested_by
      t.string :authorized_by
      t.integer :status

      t.timestamps
    end

    add_index :jobs, :project_id
    add_index :jobs, :server_id
    add_index :jobs, :status
  end
end
