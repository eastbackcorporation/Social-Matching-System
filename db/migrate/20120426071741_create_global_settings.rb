class CreateGlobalSettings < ActiveRecord::Migration
  def change
    create_table :global_settings do |t|
      t.integer :matching_range,:null=>false
      t.integer :maximum_range,:null=>false
      t.integer :matching_interval,:null=>false
      t.timestamps
    end
  end
end
