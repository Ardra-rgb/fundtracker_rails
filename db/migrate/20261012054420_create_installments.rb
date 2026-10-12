
class CreateInstallments < ActiveRecord::Migration[8.1]
  def change
    create_table :installments do |t|
      t.references :member, null: false, foreign_key: true

      t.date :month, null: false
      t.date :due_date, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :installments,
              [:member_id, :month],
              unique: true,
              name: "unique_member_installment_month"
  end
end
