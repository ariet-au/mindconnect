require "test_helper"

class PsychologistDashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get psychologist_dashboard_index_url
    assert_response :success
  end
end
