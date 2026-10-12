require "test_helper"

class CollectionPeriodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      username: "period-test",
      password: "password",
      password_confirmation: "password"
    )
    @member = @user.members.create!(
      member_id: "PER-001",
      name: "Period Test Member",
      phone: "1234567890",
      monthly_amount: 25,
      active: true
    )

    post login_url, params: {
      username: @user.username,
      password: "password"
    }
  end

  test "creates installment months and displays the period range on its month page" do
    start_month = Date.current.beginning_of_month
    end_month = start_month.next_month

    post collection_periods_url, params: {
      collection_period: {
        start_month: start_month.strftime("%Y-%m"),
        end_month: end_month.strftime("%Y-%m")
      }
    }

    assert_redirected_to dashboard_path(month: start_month.strftime("%Y-%m"))
    assert_equal [ start_month, end_month ],
                 @member.installments.order(:month).pluck(:month)

    get dashboard_path

    assert_response :success
    assert_includes response.body, start_month.strftime("%B %Y")
    assert_includes response.body, end_month.strftime("%B %Y")

    [ start_month, end_month ].each do |month|
      get dashboard_path(month: month.strftime("%Y-%m"))

      assert_response :success
      assert_includes response.body, "Monthly installments"
      assert_includes response.body, "1 pending"
      assert_select "form.payment-form input[name='payment[payment_date]']"
      assert_includes response.body, "Record"
      assert_includes response.body, start_month.strftime("%B %Y")
      assert_includes response.body, end_month.strftime("%B %Y")
    end
  end
end
