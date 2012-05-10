class AddIndexNameToStatuses < ActiveRecord::Migration
  def change
    add_index :statuses, ["name"], :name => "index_statuses_on_name", :unique => true
  end
end
