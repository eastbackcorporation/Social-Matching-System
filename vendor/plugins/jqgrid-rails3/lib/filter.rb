module JqgridFilter

	def filter_on_params (model_class) 
		grid_columns = params[:grid_columns]

		# Are we a detail grid?  If so search on the foreign attribute.
		if params.delete(:slave_detail)
			foreign_id_attribute = params.delete(:foreign_id_attribute)
			
			if !foreign_id_attribute
				# No row on the master grid has been selected so don't know what to fetch for the slave grid.
				return jqgrid_json([], grid_columns, params[:page].to_i, params[:rows].to_i, 0)
			end 
			
			# If the foreign key name matches up with the model class (relying on Rail's conventions)
			# then convert it to an id.			
			foreign_id_attribute = 'id' if foreign_id_attribute =~ Regexp.new("^#{model_class}", Regexp::IGNORECASE)		
			
			# We want  all the special filtering and sorting capabilities in detail grids as well so
			# make search true in case it isn't and as the foreign_id_attribute isn't likely to be one of the grid columns add in in temporarily.
			params[:_search] = 'true'
			params[foreign_id_attribute.to_sym] = params.delete(:foreign_id)

			# Remove :id so it doesn't influence the search on the foreign attribute.
			params.delete(:id)
		end
		
		ar_options = {}
		current_page = params[:page] ? params[:page].to_i : 1
		rows_per_page = params[:rows] ? params[:rows].to_i : 10

		# Make sorting consistent regardless if done by AR or manually.
		sort_index = params[:sidx] && params[:sidx] != '' ? params[:sidx] : :id
		sort_dir = params[:sord] || 'asc'
		ar_options[:order] = "#{sort_index} #{sort_dir}"

		# Analyse the input params to see if any have the special match conditions or are virtual attributes.
		regular_attribute_params = {}
		special_attribute_params = {}

		params.each do |c, param|
			if model_class.columns_hash[c.to_s]
				if special_match_condition?(param)
					special_attribute_params[c] = param
				else
					regular_attribute_params[c] = param
				end
			elsif model_class.method_defined?(c.to_sym) || c.to_s =~ /\./
				# virtual attribute or attribute references another table
				special_attribute_params[c] = param	
			end
		end

		sort_on_virtual_attribute = !model_class.columns_hash[sort_index.to_s] ? sort_index : false

		if !sort_on_virtual_attribute && special_attribute_params.empty?
			ar_options[:conditions] = filter_by_conditions(regular_attribute_params) if params[:_search] == "true"
			ar_options[:page] = current_page
			ar_options[:per_page] = rows_per_page
			grid_records = model_class.paginate(ar_options)
			total_entries = grid_records.total_entries
		else
			grid_records, total_entries = special_filter(model_class, grid_columns, regular_attribute_params, special_attribute_params, 
															sort_index, sort_dir,
															current_page, rows_per_page)
		end
		
		jqgrid_json(grid_records, grid_columns, current_page, rows_per_page, total_entries)
	end	

	# records may be an array of active records or an array of hashes (one entry per column)
	def jqgrid_json (records, grid_columns, current_page, per_page, total)
		json = %Q^{"page": #{current_page}, "total": #{total/per_page + 1}, "records": #{total}^
		if total > 0
			rows = records.map do |record|
				record[:id] ||= records.index(record)
				columns = grid_columns.map do |column|
					value = record[column] || get_attrib_value(record, column)
					value = escape_json(value) if value && value.kind_of?(String)
					%Q^"#{value}"^
				end
				%Q^{"id": "#{record[:id]}", "cell": [#{columns.join(',')}]}^
			end
			json << %Q^, "rows": [ #{rows.join(',')}]^
		end
		json << "}"
	end

	
	private
	
	# Convert the given columns and their values into SQL search terms while
	# protecting agains SQL injection.  Use LIKE in general but for an id field
	# this doesn't make sense so force an exact match.
	def filter_by_conditions (filter_columns)
		query = filter_columns.keys.map {|c| c =~ /id$/ ? "#{c} = ?" : "#{c} LIKE ?"}.join(' AND ')
		data = filter_columns.keys.map {|c|  c =~ /id$/ ? "#{filter_columns[c]}" : "%#{filter_columns[c]}%"}
		[query] + data
	end

	# A param is special and cannot use the normal AR find method if it is a virtual attribute or it is tagged with 
	# one of the match criteria.  
	# The prefix match criteria are:
	# 	=		exact match to following string (may be empty for empty or null attribute),
	#   !=		not match to following string (may be empty for empty or null attribute),,
	#   >		attribute is greater than follow number, similarly for >=, < and <= 
	#   ~		attribute is tested agains the following string as a regular expression for a match
	#   !~		attribute is tested agains the following string as a regular expression for not a match
	#   ^		attribute must start with the following string
	# The middle match criteria are:
	#   ..		where the attribute must be >= the before .. string/number and < the .. after string/number
	# The postfix match criteria are:
	#   $ 		attribute must end with the preceding string
	# A string with out a prefix or postfix must be contained by the attribute for a match (same as the SQL LIKE operator).
	def special_match_condition? (param)
		if	param =~ /^(=|!=|~|!~|\^|>|>=|<|<=)/ ||				# a prefix match criteria
			param =~ /.+\.\..+/					 ||				# a middle match criteria
			param =~ /\$$/										# a post fix match criteria
				true
		else
				false
		end
	end
	
	def str_to_column_type (model_class, str, col)
		begin
			value = case model_class.columns_hash[col].type
						when :string	then str
						when :text		then str
						when :integer	then str.to_i
						when :float		then str.to_f
						when :date		then Date.strptime(str, Date::DATE_FORMATS[:default] || Date::DATE_FORMATS[:number])
						when :datetime	then Time.strptime(str, Time::DATE_FORMATS[:default] || Time::DATE_FORMATS[:number])
						when :decimal 	then str.to_d
						else
							raise "need to add type conversion here for #{model_class.columns_hash[col].type.inspect} for col #{col} with string #{str}"
					end	
		rescue ArgumentError
			# The date or time conversion may have been passed an incomplete or wrong data or time to convert so return nil
			# so the filtering can be skipped until we get a good value.
			nil
		end	
	end

	# Get all the records or a subset from the database.
	def get_records (model_class, conditions)
		if conditions.empty?
			# No regular search parameters so just grab everything.
			model_class.all
		else
			# Query AR to get the super set of what we want.
			sql_query, sql_query_data = filter_by_conditions(conditions)
			model_class.where(sql_query, sql_query_data)
		end
	end

	# Convert all attribute data in each record into a simple hash, keyed with the attributes's name and
	# expanded so any virtual attributes or attributes with a path are resolved (so we only do it once).
	def record_to_hash (record, attribs)
		attribs.reduce({}) {|hsh, attrib| hsh[attrib] = get_attrib_value(record, attrib); hsh}
	end
	
	# Return the grid records that match the given param for the given col.
	def filter_by_param (model_class, grid_records, col, param)
		case param 
			when /^!~(.*)/								# does not match against user regexp
				re = Regexp.new($1, Regexp::IGNORECASE)
				grid_records.find_all {|r| r[col].to_s !~ re}
				
			when /^=(.*)/								# exact match (use re so case insensitive)
				re = Regexp.new("^#{$1}$", Regexp::IGNORECASE)
				grid_records.find_all {|r| r[col].to_s =~ re}

			when /^!=(.*)/								# exact non match (use re so case insensitive)
				re = Regexp.new("^#{$1}$", Regexp::IGNORECASE)
				grid_records.find_all {|r| r[col].to_s !~ re}

			when /^~(.*)/, /^(\^.*)/, /(.*\$)$/		# matches against user regexp, starts with, ends with
				re = Regexp.new($1, Regexp::IGNORECASE)
				grid_records.find_all {|r| r[col].to_s =~ re}

			when /^>=(.*)/								# >=
				value = str_to_column_type(model_class, $1, col)
				grid_records.find_all {|r| r[col] >= value} if value

			when /^>(.*)/								# >
				value = str_to_column_type(model_class, $1, col)
				grid_records.find_all {|r| r[col] > value} if value

			when /^<=(.*)/								# <=
				value = str_to_column_type(model_class, $1, col)
				grid_records.find_all {|r| r[col] <= value} if value

			when /^<(.*)/								# <
				value = str_to_column_type(model_class, $1, col)
				grid_records.find_all {|r| r[col] < value} if value

			when /(.+)\.\.(.+)/							# between a range
				min = str_to_column_type(model_class, $1, col)
				max = str_to_column_type(model_class, $2, col)
				if min && max
					grid_records.find_all do |r|
						value = r[col]
						value >= min && value < max
					end
				end
			else
				# Attribute with no match criteria so look for contains
				re = Regexp.new(param, Regexp::IGNORECASE)
				grid_records.find_all {|r| r[col].to_s =~ re}
		end
	end

	# Get the range of records to show.
	def paginate_records (records, current_page, rows_per_page)
		if records.length > rows_per_page
			start = (current_page - 1) * rows_per_page
			
			# Show the last full page if the start position will cause records off the end to be shown.
			start = records.length - rows_per_page if start + rows_per_page > records.length 
		else
			# Fewer records than will fit so always show them all.
			start = 0
		end
		records[start, rows_per_page]
	end
	
	def special_filter (model_class, grid_columns, regular, special, sort_index, sort_direction, current_page, rows_per_page)
		# Cache results between requests to speed up pagination and changes to sort order.  The cache will expire so is only
		# for short term use, however if any of the underlying tables are updated then the cache will *not* be invalidated
		#  (will be fixed in the future).
		cache_key = [model_class.to_s, regular, special, sort_index].inspect

		grid_records = Rails.cache.fetch(cache_key, :expires_in => 1.minutes) do
			# Cache miss, so do the work...
			grid_records = get_records(model_class, regular)

			# This is for efficiency reasons.  Include any special attributes (virtual or path to other table) as they 
			# may not be in the normal set to be displayed in grid columns.
			grid_records = grid_records.map {|record| record_to_hash(record, grid_columns + special.keys)}

			# Successively filter based on each condition
			special.each {|col, param| grid_records = filter_by_param(model_class, grid_records, col, param)}
			
			# Sort the results (this will be done on :id if non provided so as to stay consistent with the AR path)
			grid_records.sort! {|a, b| a[sort_index] <=> b[sort_index]} if sort_index != :id
			grid_records
		end

		grid_records = grid_records.reverse if sort_direction != 'asc'

		return paginate_records(grid_records, current_page, rows_per_page), grid_records.length
	end
	
	
	JSON_ESCAPE_MAP = {	  '\\'	  => '\\\\',
						  '</'	  => '<\/',
						  "\r\n"  => '\n',
						  "\n"	  => '\n',
						  "\r"	  => '\n',
						  "\v"	  => '\n',
						  '"'	  => '\\"' }

	def escape_json(json)
		json ? json.gsub(/(\\|<\/|\r\n|[\n\r"\v])/) { JSON_ESCAPE_MAP[$1] } : ''
	end

	def get_attrib_value(record, attrib)
		attrib.split('.').reduce(record) do |obj, method| 
			next_obj = obj.send(method)
			return '' if !next_obj || next_obj == ''
			next_obj
		end
	end
end

class ActionController::Base
	include JqgridFilter
end