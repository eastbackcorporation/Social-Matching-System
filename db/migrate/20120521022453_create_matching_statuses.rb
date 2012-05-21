class CreateMatchingStatuses < ActiveRecord::Migration
  def change
    create_table :matching_statuses do |t|
      t.string :name,:null=>false
      t.boolean :active_flg,:null=>false

      t.timestamps
    end
  end
end
