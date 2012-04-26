class AddMainAndNameToAddress < ActiveRecord::Migration
  def change
    add_column :addresses,:main,:bool,:null=>false
    add_column :addresses,:name,:string
  end
end
