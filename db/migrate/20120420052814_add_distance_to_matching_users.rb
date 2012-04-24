class AddDistanceToMatchingUsers < ActiveRecord::Migration
  def change
    add_column :matching_users ,:distance,:float
  end
end
