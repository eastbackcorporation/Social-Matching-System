class AddMatchingStatusIdAndRequestStatusIdToMassages < ActiveRecord::Migration
  def change
    add_column :massages,:matching_status_id,:integer,:null=>false
    add_column :massages,:request_status_id,:integer,:null=>false
  end
end
