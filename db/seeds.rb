# -*- coding: utf-8 -*-
#rake db:setup
begin
  table_names = %w(roles users categories receivers_locations request_statuses matching_statuses status_descriptions)
  table_names.each do |table_name|
    path = Rails.root.join("db", "seeds", Rails.env, "#{table_name}.rb")
    if File.exist?(path)
      puts "Seeding #{table_name}..."
      require(path)
    end
  end
 end