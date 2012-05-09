class ChangeGlobalSettings < ActiveRecord::Migration
  def change
    add_column :global_settings,:matching_number_limit,:integer,:null=>false
    change_column :global_settings,:matching_range,:float,:null=>:false
    change_column :global_settings,:maximum_range,:float,:null=>:false
    change_column :global_settings,:matching_step,:float,:null=>:false
  end
end
