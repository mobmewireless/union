class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :report_type
      t.text :data

      t.timestamps
    end

    add_index :reports, :report_type
  end
end
