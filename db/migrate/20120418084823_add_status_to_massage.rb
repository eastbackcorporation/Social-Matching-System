class AddStatusToMassage < ActiveRecord::Migration
  def change
    add_column :massages,:status_id,:integer
  end
end
