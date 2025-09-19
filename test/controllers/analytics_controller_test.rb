require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get analytics_index_url
    assert_response :success
  end

  test "should get show" do
    get analytics_show_url
    assert_response :success
  end
end
