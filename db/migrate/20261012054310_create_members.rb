class CreateMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :members do |t|
      t.references :owner,
                   null: false,
                   foreign_key: { to_table: :users }

      t.string :member_id, limit: 20, null: false
      t.string :name, limit: 150, null: false
      t.string :phone, limit: 10, null: false
      t.decimal :monthly_amount, precision: 10, scale: 2, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :members, [ :owner_id, :member_id ],
              unique: true,
              name: "unique_owner_member_id"
  end
end
