class RenameColumnReceiverIdToUserIdOfMatchingUsersTable < ActiveRecord::Migration
  def up
    rename_column :matching_users,:receiver_id,:user_id
  end

  def down
  end
end
