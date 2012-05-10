class AddActiveFlgToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses,:active_flg,:bool,:null=>false
  end
end
