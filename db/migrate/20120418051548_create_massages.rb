class CreateMassages < ActiveRecord::Migration
  def change
    create_table :massages do |t|
      t.integer :category_id
      t.integer :user_id
      t.datetime :validated_datetime
      t.datetime :active_datetime
      t.string :latitude
      t.string :longitude

      t.timestamps
    end
  end
end
