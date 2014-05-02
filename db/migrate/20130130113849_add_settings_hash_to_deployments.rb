class AddSettingsHashToDeployments < ActiveRecord::Migration
  def change
    add_column :deployments, :settings_hash, :string
  end
end
