class CreateAddresses < ActiveRecord::Migration
   def change
    create_table :addresses do |t|
      #ユーザ認証用
      t.integer    :user_id,               :null => false
      t.string    :prefecture,               :null => false
      t.string    :address1,    :null => false
      t.string    :address2,       :null => false
      t.string    :postal_code,   :null => false


      t.timestamps
    end
  end
end
