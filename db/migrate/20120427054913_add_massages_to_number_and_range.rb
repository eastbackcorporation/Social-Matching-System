class AddMassagesToNumberAndRange < ActiveRecord::Migration
  def change
    add_column :massages,:matching_count,:integer
    add_column :massages,:matching_range,:string
  end
end
