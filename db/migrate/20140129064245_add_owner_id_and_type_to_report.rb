class AddOwnerIdAndTypeToReport < ActiveRecord::Migration
  def change
    add_column :reports, :owner_id, :integer
    add_column :reports, :owner_type, :string
    add_index :reports, %w(owner_id owner_type)
  end
end
