class AddLedgerNumbersToMembers < ActiveRecord::Migration[8.1]
  class UserRecord < ActiveRecord::Base
    self.table_name = "users"
  end

  class MemberRecord < ActiveRecord::Base
    self.table_name = "members"
  end

  def up
    add_column :users, :last_member_ledger_number, :integer, default: 0, null: false
    add_column :members, :ledger_number, :integer

    UserRecord.reset_column_information
    MemberRecord.reset_column_information

    UserRecord.find_each do |user|
      number = 0

      MemberRecord.where(owner_id: user.id).order(:id).find_each do |member|
        number += 1
        member.update_columns(ledger_number: number)
      end

      user.update_columns(last_member_ledger_number: number)
    end

    change_column_null :members, :ledger_number, false
    add_index :members, [ :owner_id, :ledger_number ],
              unique: true,
              name: "unique_owner_member_ledger_number"
  end

  def down
    remove_index :members, name: "unique_owner_member_ledger_number"
    remove_column :members, :ledger_number
    remove_column :users, :last_member_ledger_number
  end
end
