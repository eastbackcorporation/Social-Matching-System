class AddAcitiveFlgAndToMassages < ActiveRecord::Migration
  def change
    add_column :massages,:active_flg,:bool,:default=>true
  end
end
