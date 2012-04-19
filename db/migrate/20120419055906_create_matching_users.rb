class CreateMatchingUsers < ActiveRecord::Migration
  def change
    create_table :matching_users do |t|
      t.integer :massage_id,:null=>false
      t.integer :receiver_id,:null=>false

      t.timestamps
    end
  end
end
