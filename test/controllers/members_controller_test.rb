require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      username: "member-edit-test",
      password: "password",
      password_confirmation: "password"
    )
    @second = create_member("M002", "Second Member", 2)
    @first = create_member("M001", "First Member", 1)
    @third = create_member("M003", "Third Member", 3)
    @user.update!(last_member_ledger_number: 3)

    post login_url, params: {
      username: @user.username,
      password: "password"
    }
  end

  test "member list has a ledger number column and edit opens a popover" do
    get dashboard_path(view: "members")

    assert_response :success
    assert_select "#members .members-table thead th", text: "No."
    assert_select "#members tbody tr:nth-child(1) .member-number", text: "1"
    assert_select "#members tbody tr:nth-child(1) .member-name", text: "First Member"
    assert_select "#members tbody tr:nth-child(2) .member-number", text: "2"
    assert_select "#members tbody tr:nth-child(2) .member-name", text: "Second Member"
    assert_select "#members .member-initial", count: 0
    assert_select "#members .members-table .member-id", count: 0
    assert_select "#members form input[name='member[member_id]']", count: 0
    assert_select "#members form label", text: /Member ID/, count: 0
    assert_select "button[popovertarget='member-edit-#{@first.id}']"
    assert_select "form#member-edit-#{@first.id}[popover='auto']"
  end

  test "deleting a member leaves other ledger numbers unchanged" do
    delete member_url(@second), params: { month: Date.current.strftime("%Y-%m") }

    assert_redirected_to dashboard_path
    assert_not Member.exists?(@second.id)
    assert_equal "M001", @first.reload.member_id
    assert_equal "M003", @third.reload.member_id

    get dashboard_path(view: "members")

    assert_response :success
    assert_select "#members tbody tr:nth-child(1) .member-number", text: "1"
    assert_select "#members tbody tr:nth-child(2) .member-number", text: "3"
    assert_select "#members tbody tr", count: 2

    post members_url, params: {
      view: "members",
      month: Date.current.strftime("%Y-%m"),
      member: {
        name: "Next Member",
        phone: "9876543210",
        monthly_amount: 50,
        active: true
      }
    }

    assert_equal 4, @user.members.find_by!(name: "Next Member").ledger_number
  end

  test "adding a member stays on the members page" do
    month = Date.current.beginning_of_month

    post members_url, params: {
      view: "members",
      month: month.strftime("%Y-%m"),
      member: {
        name: "New Member",
        phone: "9876543210",
        monthly_amount: 50,
        active: true
      }
    }

    assert_redirected_to dashboard_path(
      view: "members",
      month: month.strftime("%Y-%m")
    )

    follow_redirect!

    assert_response :success
    assert_select "#members h2", text: "Members"
    assert_select "#members .member-name", text: "New Member"
    new_member = @user.members.find_by!(name: "New Member")
    assert_equal 4, new_member.ledger_number
    assert_equal "M004", new_member.member_id
    assert Installment.exists?(
      member: new_member,
      month: month
    )
  end

  test "adding a member from overview stays on overview" do
    month = Date.current.beginning_of_month

    post members_url, params: {
      view: "overview",
      month: month.strftime("%Y-%m"),
      member: {
        name: "Overview Member",
        phone: "9876543210",
        monthly_amount: 50,
        active: true
      }
    }

    assert_redirected_to dashboard_path(
      view: "overview",
      month: month.strftime("%Y-%m")
    )

    follow_redirect!

    assert_response :success
    assert_select "#overview h1"
    assert_select "#members .member-name", text: "Overview Member"
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

  def create_member(member_id, name, ledger_number)
    @user.members.create!(
      member_id: member_id,
      ledger_number: ledger_number,
      name: name,
      phone: "1234567890",
      monthly_amount: 25,
      active: true
    )
  end
end
