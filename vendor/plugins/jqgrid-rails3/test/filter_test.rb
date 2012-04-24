require 'test_helper'

# Get access to the methods we want to test.
class TestController < ActionController::Base
	public	:get_column_value
	public	:jqgrid_json
	public 	:filter_by_conditions
	public 	:special_match_condition?
	public  :str_to_column_type
	public  :record_to_hash
	public  :filter_by_param
	public  :paginate_records
end

# This acts as a proxy for ActiveRecord in that the 'attributes' can be accessed as methods or via []. 
TestRecord = Struct.new(:a, :b, :c, :id) do
	# A virtual attribute
	def va
		a.upcase
	end
end

class TestModel
	# Proxy for an active record model returning a column hash.  The only column parameter we are interested in is type.
	Type = Struct.new(:type)
	
	attr_reader	:columns_hash
	
	def initialize (col = nil, type = nil)
		if col
			@columns_hash = { col => Type.new(type)}
		else
			@columns_hash = {	'string' 	=> Type.new(:string),
			 					'integer' 	=> Type.new(:integer),
								'float'		=> Type.new(:float),
								'decimal'	=> Type.new(:decimal),
								'date'		=> Type.new(:date),
								'datetime'  => Type.new(:datetime)
							}
		end
	end
end


class JqgridFilterTest < ActiveSupport::TestCase

	def setup
		@tc = TestController.new
	end

	def make_records (ary)
		ary.map {|c| TestRecord.new(c)}
	end	

	# ---- get_column_values ----

	test "get column values for attributes" do
		record = TestRecord.new(1, 2, 3)
		assert_equal(1, @tc.get_column_value(record, 'a'))
		assert_equal(2, @tc.get_column_value(record, 'b'))
		assert_equal(3, @tc.get_column_value(record, 'c'))
	end
	
	test "get column values for nil or '' attributes" do
		record = TestRecord.new('')
		assert_equal('', @tc.get_column_value(record, 'a'))
		assert_equal('', @tc.get_column_value(record, 'b'))
	end
	
	test "get column values for virtual attributes" do
		record = TestRecord.new('abc')
		assert_equal('ABC', @tc.get_column_value(record, 'va'))
	end
	
	# Use methods to act as attributes in other tables as in an active record
	test "get column values for attribute path" do
		record = TestRecord.new('9bc')
		assert_equal('9BC', @tc.get_column_value(record, 'a.upcase'))
		assert_equal('9', @tc.get_column_value(record, 'a.upcase.downcase.to_i.to_s'))
	end
	

	# ---- jqgrid_json ----

	test "jqgrid json record data when no records" do
		assert_equal('{"page": 1, "total": 1, "records": 0}', @tc.jqgrid_json([], %w{a b c}, 1, 2, 0))
	end

	test "jqgrid json record data when one record with string data" do
		records = [TestRecord.new("aa", "bb", "cc", 10)]
		assert_equal('{"page": 1, "total": 1, "records": 1, "rows": [ {"id": "10", "cell": ["aa","bb","cc"]}]}', @tc.jqgrid_json(records, %w{a b c}, 1, 2, 1))
	end

	test "jqgrid json record data when one record with integer data" do
		records = [TestRecord.new(1, 2, 3, 10)]
		assert_equal('{"page": 1, "total": 1, "records": 1, "rows": [ {"id": "10", "cell": ["1","2","3"]}]}', @tc.jqgrid_json(records, %w{a b c}, 1, 2, 1))
	end

	test "jqgrid json record data when one record with float data" do
		records = [TestRecord.new(1.1, 2.2, 3.3, 10)]
		assert_equal('{"page": 1, "total": 1, "records": 1, "rows": [ {"id": "10", "cell": ["1.1","2.2","3.3"]}]}', @tc.jqgrid_json(records, %w{a b c}, 1, 2, 1))
	end

	test "jqgrid json record data when one record with date data" do
		Date::DATE_FORMATS[:default] = "%d/%m/%Y"
		d1 = Date.strptime("20/1/2011", Date::DATE_FORMATS[:default])
		d2 = Date.strptime("21/2/2012", Date::DATE_FORMATS[:default])
		d3 = Date.strptime("22/3/2013", Date::DATE_FORMATS[:default])
		records = [TestRecord.new(d1, d2, d3, 10)]
		assert_equal('{"page": 1, "total": 1, "records": 1, "rows": [ {"id": "10", "cell": ["20/01/2011","21/02/2012","22/03/2013"]}]}', @tc.jqgrid_json(records, %w{a b c}, 1, 2, 1))
	end

	test "jqgrid json record data when one record with decimal data" do
		records = [TestRecord.new("1.12".to_d, "2.23".to_d, "30.33".to_d, 10)]
		assert_equal('{"page": 1, "total": 1, "records": 1, "rows": [ {"id": "10", "cell": ["1.12","2.23","30.33"]}]}', @tc.jqgrid_json(records, %w{a b c}, 1, 2, 1))
	end

	test "jqgrid json record data when two record with mixed data" do
		records = [TestRecord.new("aa", 10, 3.0, 10), TestRecord.new("bb", 20, 5.0, 11)]
		assert_equal('{"page": 1, "total": 1, "records": 1, "rows": [ {"id": "10", "cell": ["aa","10","3.0"]},{"id": "11", "cell": ["bb","20","5.0"]}]}', @tc.jqgrid_json(records, %w{a b c}, 1, 2, 1))
	end

	test "jqgrid json record data when two record with mixed data but no id so id used should be position in array" do
		records = [TestRecord.new("aa", 10, 3.0), TestRecord.new("bb", 20, 5.0)]
		assert_equal('{"page": 1, "total": 1, "records": 1, "rows": [ {"id": "0", "cell": ["aa","10","3.0"]},{"id": "1", "cell": ["bb","20","5.0"]}]}', @tc.jqgrid_json(records, %w{a b c}, 1, 2, 1))
	end

	test "jqgrid json record data when one record using a hash instead of a fake AR record" do
		records = [{'a' => "aa", 'b' => "bb", 'c' => "cc", :id => 10}]
		assert_equal('{"page": 1, "total": 1, "records": 1, "rows": [ {"id": "10", "cell": ["aa","bb","cc"]}]}', @tc.jqgrid_json(records, %w{a b c}, 1, 2, 1))
	end


	# ---- filter_by_conditions ----

	test "filter by condition with one condition" do
		assert_equal(['a LIKE ?', '%10%'], @tc.filter_by_conditions('a' => 10))
	end

	test "filter by condition with two conditions" do
		assert_equal(['a LIKE ? AND b LIKE ?', '%10%', '%bb%'], @tc.filter_by_conditions('a' => 10, 'b' => 'bb'))
	end


	# ---- special_match_condition? ----

	test "check if special match conditions are detected" do
		{
			'hello='		=> false,
			'=hello'		=> true,
			'!=hello'		=> true,
			'~hello'		=> true,
			'!~hello'		=> true,
			'>hello'		=> true,
			'<hello'		=> true,
			'<=hello'		=> true,
			'>=hello'		=> true,
			'<=hello'		=> true,
			'^hello'		=> true,
			'hello$'		=> true,
			'hel..lo'		=> true,
			' =hello'		=> false,
			' !=hello'		=> false,
			' ~hello'		=> false,
			' !~hello'		=> false,
			' >hello'		=> false,
			' <hello'		=> false,
			' <=hello'		=> false,
			' >=hello'		=> false,
			' <=hello'		=> false,
			' ^hello'		=> false,
			'hello$ '		=> false,

		}.each {|param, result| assert_equal(result, @tc.special_match_condition?(param), "For test param: '#{param}'")}
	end

	# ---- str_to_column_type ----
	
	test "str to column type conversion for string column type" do
		assert_equal("hello", @tc.str_to_column_type(TestModel.new, 'hello', 'string'))
	end

	test "str to column type conversion for fixnum column type" do
		assert_equal(1234, @tc.str_to_column_type(TestModel.new, '1234', 'integer'))
	end

	test "str to column type conversion for float column type" do
		assert_equal(3.412, @tc.str_to_column_type(TestModel.new, '3.412', 'float'))
	end

	test "str to column type conversion for decimal column type" do
		records = [TestRecord.new("42.0".to_d)]
		assert_equal("3.412".to_d, @tc.str_to_column_type(TestModel.new, '3.412', 'decimal'))
	end
	
	test "str to column type conversion for date column type" do
		Date::DATE_FORMATS[:default] = "%d/%m/%Y"
		d2 = Date.strptime("18/7/2011", Date::DATE_FORMATS[:default])
		assert_equal(d2, @tc.str_to_column_type(TestModel.new, '18/7/2011', 'date'))
	end

	test "str to column type conversion for date column type when input is incomplete" do
		assert_equal(nil, @tc.str_to_column_type(TestModel.new, '20/1/', 'date'))
	end

	# ---- record_to_hash ----

	test "converting a record to a hash, taking care of virtual attributes and attribute paths" do
		record = TestRecord.new('aa', 'BB', 22.23, 10)
		assert_equal({'va' => 'AA', 'b.downcase' => 'bb', 'c' => 22.23, 'id' => 10}, @tc.record_to_hash(record, %w{id c b.downcase va}))
	end


	# ---- filter_by_param ----
	
	test "filter records with the default 'contains' test" do
		records = make_records(%w{red orange yellow green blue indigo violet})
		assert_equal(make_records(%w{yellow blue violet}), @tc.filter_by_param(TestModel.new('a', :string), records, 'a', 'l'))
	end

	test "filter records with the default 'contains' test and it is case insensitive" do
		records = make_records(%w{red orange yellow green blue indigo violet})
		assert_equal(make_records(%w{yellow blue violet}), @tc.filter_by_param(TestModel.new('a', :string), records, 'a', 'L'))
	end

	test "filter records with the 'begins with' test" do
		records = make_records(%w{red orange yellow green blue indigo violet})
		assert_equal(make_records(%w{orange}), @tc.filter_by_param(TestModel.new('a', :string), records, 'a', '^o'))
	end

	test "filter records with the 'ends with' test" do
		records = make_records(%w{red orange yellow green blue indigo violet})
		assert_equal(make_records(%w{indigo}), @tc.filter_by_param(TestModel.new('a', :string), records, 'a', 'o$'))
	end

	test "filter records that match a regular expression' test" do
		records = make_records(%w{red orange yellow green blue indigo violet})
		assert_equal(make_records(%w{red}), @tc.filter_by_param(TestModel.new('a', :string), records, 'a', '~^...$'))
	end

	test "filter records that don't match a regular expression' test" do
		records = make_records(%w{red orange yellow green blue indigo violet})
		assert_equal(make_records(%w{orange yellow green blue indigo violet}), @tc.filter_by_param(TestModel.new('a', :string), records, 'a', '!~^...$'))
	end

	test "filter records that exactly match' test" do
		records = make_records(%w{red reddy wreddy})
		assert_equal(make_records(%w{red}), @tc.filter_by_param(TestModel.new('a', :string), records, 'a', '=RED'))
	end

	test "filter records that do not exactly match' test" do
		records = make_records(%w{red reddy wreddy})
		assert_equal(make_records(%w{reddy wreddy}), @tc.filter_by_param(TestModel.new('a', :string), records, 'a', '!=RED'))
	end

	test "filter records that are less than' test" do
		records = make_records([1, 2, 3, 4, 5, 6])
		assert_equal(make_records([1, 2, 3]), @tc.filter_by_param(TestModel.new('a', :integer), records, 'a', '<4'))
	end

	test "filter records that are less than or equal' test" do
		records = make_records([1, 2, 3, 4, 5, 6])
		assert_equal(make_records([1, 2, 3, 4]), @tc.filter_by_param(TestModel.new('a', :integer), records, 'a', '<=4'))
	end

	test "filter records that are greater than' test" do
		records = make_records([1, 2, 3, 4, 5, 6])
		assert_equal(make_records([5, 6]), @tc.filter_by_param(TestModel.new('a', :integer), records, 'a', '>4'))
	end

	test "filter records that are greater than or equal' test" do
		records = make_records([1, 2, 3, 4, 5, 6])
		assert_equal(make_records([4, 5, 6]), @tc.filter_by_param(TestModel.new('a', :integer), records, 'a', '>=4'))
	end
	
	test "filter records that are in a range' test" do
		records = make_records([1, 2, 3, 4, 5, 6])
		assert_equal(make_records([3, 4]), @tc.filter_by_param(TestModel.new('a', :integer), records, 'a', '3..5'))
	end
	
	# ---- paginate_records ----
	
	test "pagination where there are fewer records than the page will hold" do
		records = [1, 2, 3, 4]
		assert_equal([1, 2, 3, 4], @tc.paginate_records(records, 2, 10))
	end
	
	test "pagination for a middle page" do
		records = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
		assert_equal([7, 8, 9], @tc.paginate_records(records, 2, 3))
	end
	
	test "pagination for an end page" do
		records = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
		assert_equal([8, 9, 10, 11, 12], @tc.paginate_records(records, 3, 5))
	end
	
end
