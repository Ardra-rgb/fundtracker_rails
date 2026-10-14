require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index when logged in" do
    user = User.create!(
      username: "dashboard_test_user",
      password: "testpassword123",
      password_confirmation: "testpassword123"
    )

    post login_path, params: {
      username: user.username,
      password: "testpassword123"
    }

    get dashboard_path

    assert_response :success
  end
end
