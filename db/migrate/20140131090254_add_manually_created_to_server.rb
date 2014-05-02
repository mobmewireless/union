class AddManuallyCreatedToServer < ActiveRecord::Migration
  def change
    add_column :servers, :manually_created, :boolean, default: false
  end
end
