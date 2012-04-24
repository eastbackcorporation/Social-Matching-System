# This generator will create the controller and view files to support jqrid tables.
# When master-detail tables are not used then the command line is 
#  rails generate jqgrid controller_name column_name_1 column_name_2 column_name_n
#  so for example 
#    rails generate jqgrid user id pseudo email firstname
#  will generate a table with columns id, pseudo, email and firstname with a controller called users_controller.rb and 
#  an index.erb in the views/users directory.


# When master-detail tables are  used first entries are the the master and entries starting with a + are 
# for a (or next) detail, i.e. (\ is to indicate line continuation)
#
#  rails generate jqgrid controller_name column_name_1 column_name_2 column_name_n \
#	+detail_1_class_name detail_1_model_name detail_1_foreign_key detail_1_column_name_1 detail_1_column_name_2 \
#   +detail_2_class_name detail_2_model_name  detail_2_foreign_key detail_2_column_name_1 detail_2_column_name_2  
#
#  The + indicates the start of a new detail (and there can be any number of them).  
#  The detail_class_name gives the name of the controller class and the file name where the class is stored.  It 
#     will be converted into the standard rails convention for controller classes and filenames).
#  The model_class_name is the name of the model used to look up the grid attributes.
#  The detail_foreign_key is the name of the column in the master table (and hence attribute name of the master model) 
#     to use to find records in the detail_model with the same detail_foreign_key attribute that correspond to the 
#     selected row in the master grid. This will be converted to just 'id' if the prefix matches the model's name, 
#     if necessary.

# An example is:
#    rails generate jqgrid user id pseudo email firstname \
#      +user_address address user_id line_1 line_2 city county post_code
# will generate two controllers called users_controller.rb and users_addresses_controller.rb holding classes
# UsersController and UsersAddressesController, accessing models User and Address.  The selected row in the user grid
# will provide the user_id (taken from the id attribute as the foreign_key is prefixed with the model's name) and its
# value will be used to find entries in the Address model that match the user_id attribute.  The master grid will
# show 4 columns and the detail grid with show 5 columns.

require 'pp'

Grid = Struct.new(:klass, :model, :foreign_key, :columns, :detail_grid) do
	def filename
		klass.split('_').map {|w| w.pluralize}.join('_') + "_controller.rb"
	end
	
	def class_name
		klass.split('_').map {|w| w.pluralize.capitalize}.join
	end
	
	def model_name
		model.split('_').map {|w| w.capitalize}.join		
	end
	
	def resource_name
		klass.split('_').map {|w| w.pluralize}.join('_')
	end
end

class JqgridGenerator < Rails::Generators::NamedBase

	argument :columns, :type => :array, :default => [], :banner => "column column"

	source_root File.expand_path('../templates', __FILE__)

	attr_reader	:grid, :grids
	
	def create_controller_files
		# Split out any detail grids.
		@grids = [[name]]
		columns.each {|c| c =~ /^\+(.*)/ ? @grids << [$1] : @grids.last << c}

		# Convert the input parameters into a more accessible form.
		@grids.each_with_index do |g, i| 
			if i == 0
				@grids[i] = Grid.new(g[0], g[0], nil, g[1..-1], false)
			else
				@grids[i] = Grid.new(g[0], g[0], g[1], g[2..-1], true)
			end
		end
		puts @grids.inspect		
		
		# Controllers for grids
		@grids.each do |grid|
			@grid = grid
			template 'controller.rb', File.join('app/controllers', class_path, "#{grid.filename}")  
		end

		@grid = @grids[0]
		template 'index.html.erb', File.join('app/views', file_path.pluralize, "index.html.erb")  
	end
end
