class AddMatchingStepToGlobalSetting < ActiveRecord::Migration
  def change
    add_column :global_settings,:matching_step,:float
  end
end
