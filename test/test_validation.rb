require 'helper'

class TestValidation < Test::Unit::TestCase
  setup do
    @api = GeekierFactory.factorize(File.join(File.dirname(File.expand_path(__FILE__)), 'mock_definition.json'))
    @action = @api.available_actions["test api"].first
  end

  test "should complain if all mandatory parameters are missing" do
    assert_raise GeekierFactory::Action::AttributesMissing do
      @action.call
    end
  end

  test "should complain if any one mandatory parameter is missing" do
    params = {:q1 => 'a', :b1 => 'b', :action => 'c'}
    params.keys.each do |mp|
      hsh = params.dup
      hsh.delete(mp)
      assert_raise GeekierFactory::Action::AttributesMissing do
        @action.call hsh
      end
    end
  end

  test "should complain if any non-mandatory path parameter is missing (because I don't know yet what to do when those are missing)" do
    params = {:q1 => 'a', :b1 => 'b', :action => 'c'}
    assert_raise GeekierFactory::Action::AttributesMissing do
      @action.call params
    end
  end
  
  test "should complain if a parameter is the wrong type" do
    params = {:q1 => 'a', :b1 => 'b', :action => 'c'}
    wrong_values = [{}, 4, true, nil, [], Object.new]
    wrong_values.each do |wval|
      assert_raise GeekierFactory::Action::ValidationException do
        @action.call params.merge(:format => wval)
      end
    end
  end
  
  test "should complain if a parameter is not included in a list" do
    params = {:q1 => 'a', :b1 => 'b', :action => 'c'}
    assert_raise GeekierFactory::Action::ValidationException do
      @action.call params.merge(:format => 'xml')
    end
  end
  
  test "should complain if a parameter is not included in a range" do
    params = {:q1 => 'a', :b1 => 'b', :action => 'c', :format => 'json'}
    assert_raise GeekierFactory::Action::ValidationException do
      @action.call params.merge(:b3 => 7)
    end
  end
end