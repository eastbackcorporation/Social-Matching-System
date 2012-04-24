require 'rubygems'
require 'test/unit'
require 'active_support'

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'
 
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
 
def load_schema
	config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
	ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

	ActiveRecord::Base.establish_connection(config[db_adapter])
	load(File.dirname(__FILE__) + "/schema.rb")
	require File.dirname(__FILE__) + '/../rails/init'
end