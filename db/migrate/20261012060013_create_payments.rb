
class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :installment,
                   null: false,
                   foreign_key: true,
                   index: { unique: true }

      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :payment_date, null: false
      t.string :reference, limit: 100, null: false, default: ""

      t.references :recorded_by,
                   null: true,
                   foreign_key: {
                     to_table: :users,
                     on_delete: :nullify
                   }

      t.timestamps
    end
  end
end
