class AddNameToGlobalSetting < ActiveRecord::Migration
  def change
    add_column :global_settings ,:name,:string
  end
end
