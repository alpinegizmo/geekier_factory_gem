require 'helper'
require "webmock"

class TestFactory < Test::Unit::TestCase
  include WebMock::API
  
  setup do
    @api = GeekierFactory.factorize(File.join(File.dirname(File.expand_path(__FILE__)), 'mock_definition.json'))
    @action = @api.available_actions["test api"].first
  end

  test "api should be factorized" do
    assert @api
    assert @api.is_a? GeekierFactory::API
  end

  test "api should have one operation with action" do
    assert_equal 1, @api.available_actions.size
    assert @api.available_actions.is_a? Hash
    assert_equal 1, @api.available_actions["test api"].size
  end

  test "action should have 4 parameters" do
    assert_equal 7, @action.params.size
    assert_equal ['q1', 'q2', 'b1', 'b2', 'b3', 'action', 'format'], @action.params.map{ |p| p['name'] }
  end

  test "action should have 2 body and 2 query parameters and they should be different" do
    assert_equal 3, @action.body_params.size
    assert_equal 2, @action.url_params.size
    assert_not_equal @action.body_params, @action.url_params
  end

  test "calling the action should call the right url" do
    stub_http_request(:post, "localhost/api/v0.1/call.json").
      with(:body => {:b1 => "body", :b3 => 3}, :query => {:q1 => 'testing', :q2 => 'query'})
    @action.call(:b1 => "body", :b3 => 3, :q1 => 'testing', :q2 => 'query', :action => 'call', :format => 'json')
  end
end