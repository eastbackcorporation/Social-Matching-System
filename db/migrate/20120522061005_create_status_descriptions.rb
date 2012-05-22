class CreateStatusDescriptions < ActiveRecord::Migration
  def change
    create_table :status_descriptions do |t|
      t.integer :request_status_id,:null=>false
      t.integer :matching_status_id,:null=>false
      t.text :description

      t.timestamps
    end
  end
end
