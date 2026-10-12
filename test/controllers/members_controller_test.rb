require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      username: "member-edit-test",
      password: "password",
      password_confirmation: "password"
    )
    @second = create_member("M002", "Second Member")
    @first = create_member("M001", "First Member")
    @third = create_member("M003", "Third Member")

    post login_url, params: {
      username: @user.username,
      password: "password"
    }
  end

  test "member list is numbered in member ID order and edit opens a popover" do
    get dashboard_path(view: "members")

    assert_response :success
    assert_select "#members tbody tr:nth-child(1) td:nth-child(1)", text: "1"
    assert_select "#members tbody tr:nth-child(1) td:nth-child(2)", text: "First Member"
    assert_select "#members tbody tr:nth-child(2) td:nth-child(1)", text: "2"
    assert_select "#members tbody tr:nth-child(2) td:nth-child(2)", text: "Second Member"
    assert_select "button[popovertarget='member-edit-#{@first.id}']"
    assert_select "form#member-edit-#{@first.id}[popover='auto']"
  end

  test "deleting a member closes the displayed numbering gap and keeps other IDs" do
    delete member_url(@second), params: { month: Date.current.strftime("%Y-%m") }

    assert_redirected_to dashboard_path
    assert_not Member.exists?(@second.id)
    assert_equal "M001", @first.reload.member_id
    assert_equal "M003", @third.reload.member_id

    get dashboard_path(view: "members")

    assert_response :success
    assert_select "#members tbody tr:nth-child(1) td:nth-child(1)", text: "1"
    assert_select "#members tbody tr:nth-child(2) td:nth-child(1)", text: "2"
    assert_select "#members tbody tr", count: 2
  end

  test "member details can be edited from the popover form" do
    patch member_url(@first), params: {
      member: { name: "Updated Member", phone: "9876543210" }
    }

    assert_redirected_to dashboard_path
    assert_equal "Updated Member", @first.reload.name
    assert_equal "9876543210", @first.phone
  end

  private

  def create_member(member_id, name)
    @user.members.create!(
      member_id: member_id,
      name: name,
      phone: "1234567890",
      monthly_amount: 25,
      active: true
    )
  end
end
