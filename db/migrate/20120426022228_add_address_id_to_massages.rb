class AddAddressIdToMassages < ActiveRecord::Migration
  def change
    add_column :massages,:address_id,:integer
  end
end
