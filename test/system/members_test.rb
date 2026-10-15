require "test_helper"

class MembersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  test "adding a member creates an automatically numbered ledger entry" do
    User.create!(
      username: "system-test-user",
      password: "password",
      password_confirmation: "password"
    )

    visit login_path
    fill_in "Username", with: "system-test-user"
    fill_in "Password", with: "password"
    click_button "Sign in"

    click_link "Members"
    fill_in "Name", with: "Ledger Member"
    fill_in "Phone", with: "9876543210"
    fill_in "Monthly amount (₹)", with: "50"
    click_button "Add member"

    assert_text "Member added."
    assert_selector "#members tbody tr .member-number", text: "1"
    assert_selector "#members tbody tr .member-name", text: "Ledger Member"
  end
end
