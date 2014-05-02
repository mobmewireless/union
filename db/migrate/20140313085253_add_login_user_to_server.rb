class AddLoginUserToServer < ActiveRecord::Migration
  def change
    add_column :servers, :login_user, :string
  end
end
