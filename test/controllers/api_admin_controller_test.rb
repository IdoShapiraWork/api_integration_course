require 'test_helper'

class ApiAdminControllerTest < ActionDispatch::IntegrationTest
  test "should get api_admin" do
    get api_admin_api_admin_url
    assert_response :success
  end

end
