class UpdateServers < ActiveRecord::Migration
  def change
    remove_column :servers, :host
    remove_column :servers, :port
    remove_column :servers, :login_user
  end
end
