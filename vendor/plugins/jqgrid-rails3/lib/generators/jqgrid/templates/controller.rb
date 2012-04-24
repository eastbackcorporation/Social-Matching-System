class <%= grid.class_name %>Controller < ApplicationController
	respond_to :html,:json
  
	# Don't forget to edit routes.  :create, :update, :destroy should only be
	# present if your jqgrid has add, edit and del actions defined for it.
	# 
	# resources :<%=grid.resource_name%>, :only => [:index, :create, :update, :destroy]

	def index
		respond_with() do |format|
			format.json {render :json => filter_on_params(<%=grid.model_name%>)}  
		end
	end

 	# PUT /<%=grid.resource_name%>/1
	def update
		grid_edit(<%=grid.model_name%>)
	end
	
	# DELETE /<%=grid.resource_name%>/1
	def destroy
		grid_del(<%=grid.model_name%>)
	end
 
	# POST /<%=grid.resource_name%>
	def create
		grid_add(<%=grid.model_name%>)
	end
end
