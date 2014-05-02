class AddLoggingToServer < ActiveRecord::Migration
  def change
    add_column :servers, :logging, :boolean
  end
end
