class AddLocationsValidatedTimeToGlobalSettings < ActiveRecord::Migration
  def change
    add_column :global_settings,:validated_time_interval,:integer,:null=>false
  end
end
