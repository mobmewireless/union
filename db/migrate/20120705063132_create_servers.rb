class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :server_name
      t.text :host
      t.integer :port
      t.string :login_user

      t.timestamps
    end
  end
end
