require 'test_helper'

class ApiUserControllerTest < ActionDispatch::IntegrationTest
  test "should get user_requests" do
    get api_user_user_requests_url
    assert_response :success
  end

end
