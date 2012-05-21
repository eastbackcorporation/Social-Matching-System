class AddEndFlgToMassages < ActiveRecord::Migration
  def change
    add_column :massages,:end_flg,:boolean,:default=>false
  end
end
