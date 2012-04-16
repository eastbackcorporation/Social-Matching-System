class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name ,:null =>false

      t.timestamps
    end
    create_table :roles_users, :id => false do |t|
      t.integer :role_id
      t.integer :user_id
    end
  end
end
