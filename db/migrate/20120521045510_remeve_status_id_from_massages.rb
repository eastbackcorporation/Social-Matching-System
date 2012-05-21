class RemeveStatusIdFromMassages < ActiveRecord::Migration
  def up
    remove_column :massages,:status_id
  end

  def down
    add_column :massages,:status_id,:integer
  end
end
