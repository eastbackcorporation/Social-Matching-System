class AddProfileToUsers < ActiveRecord::Migration
  def change
    add_column :users,:given_name,:string
    add_column :users,:family_name,:string
    add_column :users,:given_name_kana,:string
    add_column :users,:family_name_kana,:string
    add_column :users,:phone_number,:string
    add_column :users,:sex,:string
    add_column :users,:date_of_birth,:date
  end
end
