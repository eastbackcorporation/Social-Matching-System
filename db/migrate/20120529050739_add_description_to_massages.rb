class AddDescriptionToMassages < ActiveRecord::Migration
  def change
    add_column :massages, :description,:text
  end
end
