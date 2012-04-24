module JqgridCRUD
	private
	
	def grid_add (model_class)
 		grid_columns = params[:grid_columns]
		record = model_class.create(model_params(model_class, grid_columns))
		grid_response(model_class, record)
	end

	def grid_edit (model_class)
 		grid_columns = params[:grid_columns]
		record = model_class.find(params[:id])
		record.update_attributes(model_params(model_class, grid_columns))

		record_data = {}
    grid_response(model_class, record)
	end
	
	def grid_del (model_class)
 		grid_columns = params[:grid_columns]
		model_class.destroy_all(:id => params[:id].split(","))
		grid_response(model_class)
	end

	# Find the attributes that match the model's table columns.
	def model_params (model_class, grid_columns)
		model_params = {}
		grid_columns.each do |c| 
			# Check if the column exists in the parameters and that it exists in the table (if may be a virtual attribute, for example).
			if params[c] && model_class.columns_hash[c]
				model_params[c] = str_to_column_type(model_class, params[c], c)
			end
		end
		model_params
	end
	
	def grid_response (model_class, record = nil, record_data = nil)
 		if !record || record.errors.empty?
			render :json => [false, '', record_data] 
		else
			error_message = "<table>"
			record.errors.entries.each do |error|
				error_message << "<tr><td><strong>#{model_class.human_attribute_name(error[0])}</strong></td> <td>: #{error[1]}</td><td>"
			end
			error_message << "</table>"
			render :json =>[true, error_message, record_data]
		end
		
	end
end

class ActionController::Base
	include JqgridCRUD
end