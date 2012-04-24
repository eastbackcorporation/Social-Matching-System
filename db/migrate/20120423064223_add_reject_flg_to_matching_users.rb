class AddRejectFlgToMatchingUsers < ActiveRecord::Migration
  def change
    add_column :matching_users,:reject_flg,:boolean, :default => false
  end
end
