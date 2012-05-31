class ChangeColumnMassageOption < ActiveRecord::Migration
  def up
    change_column :massages,:latitude,:string,:null => false
    change_column :massages,:longitude,:string,:null => false
  end

  def down
  end
end
