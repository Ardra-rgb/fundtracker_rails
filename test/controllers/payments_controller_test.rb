require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      username: "payment-test",
      password: "password",
      password_confirmation: "password"
    )
    @member = @user.members.create!(
      member_id: "PAY-001",
      name: "Cash Payment Member",
      phone: "1234567890",
      monthly_amount: 25,
      active: true
    )
    @month = Date.current.beginning_of_month
    @installment = @member.installments.create!(
      month: @month,
      due_date: @month,
      amount: 25
    )
    @previous_month = @month.prev_month
    @previous_installment = @member.installments.create!(
      month: @previous_month,
      due_date: @previous_month,
      amount: 25
    )

    post login_url, params: {
      username: @user.username,
      password: "password"
    }
  end

  test "records and displays a payment on the payments and month pages" do
    get dashboard_path

    assert_response :success
    assert_select "form.payment-form input[name='payment[payment_date]']"
    assert_select "form.payment-form input[name='payment[reference]']"

    post installment_payment_url(@previous_installment), params: {
      payment: {
        payment_date: Date.current.iso8601,
        reference: "Cash"
      },
      month: @previous_month.strftime("%Y-%m")
    }

    assert_redirected_to dashboard_path(
      month: @previous_month.strftime("%Y-%m")
    )
    assert_equal 1, Payment.count

    get dashboard_path(view: "payments", member_name: "Cash Payment")

    assert_response :success
    assert_includes response.body, "Cash Payment Member"
    assert_includes response.body, "Cash"
    assert_includes response.body, "1 recorded"
    assert_select "#payments tbody tr td:first-child", text: "1"
    assert_includes response.body, Date.current.strftime("%b %-d, %Y")

    get dashboard_path(month: @previous_month.strftime("%Y-%m"))

    assert_response :success
    assert_includes response.body, "Cash Payment Member"
    assert_includes response.body, "Cash"
    assert_includes response.body, Date.current.strftime("%b %-d, %Y")
    assert_select "#payments tbody tr td:first-child", text: "1"
    assert_includes response.body, "Monthly installments"
    assert_includes response.body, "All installments are paid for this month."
  end
end
