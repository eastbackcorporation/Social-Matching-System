class CreateReceiversLocations < ActiveRecord::Migration
  def change
    create_table :receivers_locations do |t|
      t.integer :user_id
      t.string :latitude
      t.string :longitude

      t.timestamps
    end
  end
end
