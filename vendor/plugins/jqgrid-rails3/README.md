# A plugin base on 2dcJqgrid for rails3 to use jqgrid

This Rails plugin allows you to add jQuery datagrids into your applications.

Following features are supported :

- Ajax enabled
- Sorting
- Pagination
- Search
- CRUD operations (add, edit, delete and read)
- Multi-selection (checkboxes)
- Master-details
- Themes
- And more ...

## Install and Uninstall 
  
	$ rake jqgrid:install
	$ rake jqgrid:uninstall
  
## Generator

You can generate a grid using a command like this one:

	$ rails generate jqgrid user id pseudo email firstname

it will create a controller and a view file to the app path.  You **must** change route to use it.  See the documentation in the generated controller.

## Use

In the app/views/layouts/application.html.erb add the following lines into the *head* section:
 
	<%= jqgrid_javascripts %>
	<%= jqgrid_stylesheets %>

  
If you want to use other theme add the theme to the stylesheets:
  
	<%= jqgrid_stylesheets 'theme' %>
  
where the theme is in /public/stylesheets/jqgrid/themes (Rails < 3.1) or /vendor/assets/stylesheets/jqgrid/themes.

Copyright (c) 2010 Anthony Heukmes, released under the MIT license   
Copyright (c) 2011 Dave Baldwin, released under the MIT license

## Creating a grid on a view

The documentation and examples for jqgrid can be found here:

[http://www.trirand.com/jqgridwiki/doku.php?id=wiki:jqgriddocs](http://www.trirand.com/jqgridwiki/doku.php?id=wiki:jqgriddocs)  
[http://www.trirand.com/blog/jqgrid/jqgrid.html](http://www.trirand.com/blog/jqgrid/jqgrid.html)

If you ran the generator above you will end up with a view file that looks like:

	<%=raw jqgrid("Users Listing ", "Users", "/users", 
	[ 
			{ :name => "id", :label => "id" }, 
			{ :name => "pseudo", :label => "pseudo" }, 
			{ :name => "email", :label => "email" }, 
			{ :name => "firstname", :label => "firstname" } 
	], 
	{
		:autowidth => true,
	} 
	) %>
	
The jqgrid method call has 5 parameters and they are:

1. The caption to add to the grid.
2. The grid's id and this must be unique for every grid in a view.
3. The url used to communicate with the server.  The routes will need to be set up to accept this url.
4. An array of column descriptors.  Each descriptor is a hash holding :name and :label values.  The :name is the name that this column has as far as the controller is concerned.  The :label is the string displayed in the column header.  Additional options can be included here to control formatting, editing, spacing, etc. and a list can be found here: [http://www.trirand.com/jqgridwiki/doku.php?id=wiki:colmodel_options](http://www.trirand.com/jqgridwiki/doku.php?id=wiki:colmodel_options).
5. A hash of options for the grid.  Only one is shown here - more as a place holder - and a list of options can be found here: [http://www.trirand.com/jqgridwiki/doku.php?id=wiki:options](http://www.trirand.com/jqgridwiki/doku.php?id=wiki:options).

The :name option in the column descriptors is used to get a value out of the model to be displayed in the corresponding column.  The :name option can be:

* An attribute name in the model.
* A virtual attribute (or method) name in the model.
* A path to an attribute or virtual attribute in another model.  This relies on relationships being established between models using belongs\_to, has\_many, etc. in the models.  If, for example, :name => 'address.city'  would use the relationship with the address model to look up the city attribute.  A '.' joins the components of the path together and the path can be arbitrary long.

### Options

The options (for a column or grid) are used exactly as in the jqgrid documentation without any Rubyification.  The option key can be a symbol or string and the option value can be a ruby type or string.  For example both these are equivalent:

	:rowList => [10, 20, 30]
	'rowList' => '[10, 20, 30]'
	
There is a hierarchy of defaults for the options.  

For the column options their default values are those provided directly by jqgrid.  

For the grid options the options in high to low priority are:

*	user jqgrid options.  These are the options you supply in the call to jqgrid in your view.
*	global options.  These are the options you want to apply to all your grids in you views.
*   rails plugin options.  These are the option built into the plugin and can be examined by looking in the vendor/plugins/jqgrid-rails3/lib/view.rb file.
*	jqgrid options.  These are the defaults baked into jqgrid itself and can be found in the jqgrid documentation.

The global options are held in a file in the config/initializers folder.  Its name doesn't matter but jqgrid.rb would seem appropriate.  The file's contents will look something like (but with your choice of options):

	# Be sure to restart your server when you modify this file.
	JqgridView::jqgrid_app_grid_options :multiselect    => true, 
										:multiboxonly   => true,
										:column_chooser => true,
	 									:add            => true, 
										:edit_method    => :inline, 
										:delete         => true, 
										:scroll         => 1, 
										:rowNum         => 50
	

A few jqgrid options are used by the plugin to provide CRUD and RESTful interfaces and are not available to the user.  They are :serializeRowData, :serializeGridData and :onclickSubmit for :add_options.  An exception will be raised if you try to use these. 


### Filtering or Searching

Records shown in the grid can be filtered using toolbar filtering (this may work for 'form filtering' but I don't use this).  Filtering works for attribute columns, virtual attribute columns and columns holding paths to other model attributes.

The value entered into the column search field will match if the attribute contains the value.  This is case insensitive.  The search value can be augmented with various adornments to restrict the  match criteria (many of these are taken from regular expressions).  

The prefix match criteria are:

* 	=		exact match to following string (may be empty for empty or null attribute).
*   !=		not match to following string (may be empty for empty or null attribute).
*   >		attribute is greater than follow number, similarly for >=, < and <= .
*   ~		attribute is tested agains the following string as a regular expression for a match
*   !~		attribute is tested agains the following string as a regular expression for not a match
*   ^		attribute must start with the following string

For example ^bill in the name field will only match names starting with bill, ~(bill|fred) in the name field will match names containing bill or fred, ~^(bill|fred) will match names starting with bill or fred.

The middle match criteria are:

*   ..		where the attribute must be >= the before .. string/number and < the .. after string/number

For example 10..20 in the price field will only match prices in greater than 10 and less than or equal to 20.

The postfix match criteria are:

*   $ 		attribute must end with the preceding string

For example win$ in the name field will only match names ending with 'win'.

### Edit Method

The :edit_method option can be set to :inline or :form.  When the :edit_method is :inline double clicking on a row will allow those columns give with :editable => true.  The escape key or clicking in another row will abandon a partially edited row.  If the edited row passed validation in the model then the row is refreshed from the model so any virtual attributes will be updated correctly.

### Column Chooser
The column chooser allows you to hide and/or rearange the columns in the grid.  It is disabled by default and the :column_chooser => true option will enable it.  Inline editing works as expected after the columns have changed, however there is a known bug in jqgrid when the toolbar filtering that basically makes it unusable.

selection selection_handler
error_handler_options

### Master Detail

The master detail facility allows the master grid in a view to control what content one or more slave grids will display when a row in the master grid is selected.  For example you may have a list of customers being shown in the master grid and the slave grid may show outstanding invoices for the selected customer.

The master detail grid has an option called :master_details.  This will reference either a hash or an array of hashes if there is more than one slave grid.  The hash has four parameters:

*	:grid_id				=> this holds the id of the slave grid
*	:caption				=> caption string to display in the grid's title area.
*	:foreign_key_column		=> this is the name of the column in the master table holding the foreign key.  i.e. the value in this column of the selected row will be used to search for matching records in the detail table.
*	:detail_foreign_key		=> this is the the attribute in the detail table to match the value of the selected master foreign key against.  If the it is the same as the foreign_key_column name then it can be omitted.

	
The caption displayed in slave detail grids can now use arbitrary values from the selected master row.  $name entries in the caption string will be replaced the the column with name value in the selected row.  If no $name entries are present then the value for the foreign_key_column will be appended to the caption.  For example if the master grid had columns forename and surname then a payments grid could have a caption:

	:caption => "Payments from $forename $surname:"

The controller used by the slave grid can be any controller tied to the model the slave grid is showing.  Nothing special is needed in the controller to function in a slave capacity and similarly the slave jqgrid has no extra or different option either.
A more complete example is:

	:master_details => 
	[
		{:grid_id => "Boats", :caption => "Boat details for $forename $surname:", :foreign_key_column => "id", :detail_foreign_key => "member_id"}, 	
		{:grid_id => "Payments", :caption => "Payment details for id: ", :foreign_key_column => "id", :detail_foreign_key => "member_id"},
	]

### External Controls

External controls (i.e. buttons, drop down menus, etc.) are controls that live outside of the jqgrid but interact with the controller through the grid.  Controls independent of the grid will work as regular Rails controls but can only influence a jqgrid by reloading the page.  

When a control changes it can cause a reload event on the grid.  The grid will then sample the control's value and pass this to the controller in the params hash.  When suitably configured the control's value can be used automatically in a filter or search operation, but is can also be ignored as far as this is concerned and additional code in the controller's index, update, create or destroy methods can make use of it for some arbitrary way.

There are two parts to setting up an external control.  

1. The control must be instantiated in your view and given an id.  The values associated with the control can be used as provided in the control or mapped to something else before being passed to the controller.  If you want a change in the control's state to be registered by the grid the control's onChange parameter will need to call some javascript to trigger a reload of the grid.  A helper method called reload_grid(grid_name) is available to simplify this.

2. The grid's options must have an entry called :external_controls. This will reference a hash (for a single control) or an array of hashes (for multiple controls).  The hash will hold a control's parameters.

The control keys are:

*	:control_id				=> this holds the id of the control to interrogate whenever the grid is communicating with the Rail's controller
*	:attib_name				=> this holds the name of the attribute to pass the control's value back to the Rail's controller.  This will typically be the same as one of the model's attributes or methods (virtual attributes), but could be some arbitrary name if the controller is going to read and act on it.
*	:use_in_search			=> this defaults to false, but should be set to true if you want this attrib_name attribute to be automatically used in a search of the model.
*	:mapping				=> this is optional and if not present whatever value is associated with the control's state will be used as provided by the control.  If it is present it is a hash of control values that determine how they are mapped into attrib_name, value and use_in_search parameters.  If a control value mapping is not present the mapping will default to that specified in the attrib_name and use_in_search values defined for the control.  A control value mapping can be empty in which case this control value will pass nothing back to the controller.
	
Each control mapping is a hash with the following keys:

*	:attib_name				=> as above
*	:use_in_search			=> as above
*	:value					=> the value to send to the controller 
	
A couple of examples may make this clearer.

You have a list of members and you want to show the members that live in the country selected by a drop down menu.  The members model has a country attribute.

Insert the drop down menu in the view using the Rail's select_tag helper:

	<%= select_tag(:country, options_for_select(['UK', 'USA', 'France', 'Germany', 'Italy']), 
		:onChange => reload_grid('Members')) %>

In the 'Members' grid include the option:

	:external_controls => {:control_id => 'country', :attrib_name => 'country', :use_in_search => true}


You have a list of members and you want to show current members, past members, and current and past members.  The members model has a virtual attribute called current_member and it returns 'true' or 'false'

Insert the drop down menu in the view using the Rail's select_tag helper:

	<%= select_tag(:current_member, options_for_select([['Current Members', 0], ['Past Members', 1], ['All Members', 3]]), 
			:onChange => reload_grid('Members')) %>

In the 'Members' grid include the option:
	
	:external_controls => [
		{:control_id => 'current_member', :attrib_name => 'current_member', :use_in_search => true, 
			:mapping => { 0 => {:attrib_name => 'current_member', :value => 'true', :use_in_search => true},
						  1 => {:attrib_name => 'current_member', :value => 'false', :use_in_search => true},
						  2 => {},
					    }
		}
	]
	
This uses an array of controls, even though there is only one.  Also note if we don't search on current_member then we get all members and this is what control value 2 gives us.	


### TODO

context menu

selection options/handler

error handlers

view.rb has all the extras
