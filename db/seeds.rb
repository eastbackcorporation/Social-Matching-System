# -*- coding: utf-8 -*-
#rake db:setup
begin
  table_names = %w(roles users statuses categories receivers_locations)
  table_names.each do |table_name|
    path = Rails.root.join("db", "seeds", Rails.env, "#{table_name}.rb")
    if File.exist?(path)
      puts "Seeding #{table_name}..."
      require(path)
    end
  end
end