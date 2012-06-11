class AddDeletion < ActiveRecord::Migration
  def up
    add_column :addresses,:deletion_flg,:bool,:default => false
  end

  def down
    remove_column :addresses,:deletion_flg
  end
end
