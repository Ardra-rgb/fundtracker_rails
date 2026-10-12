
class CreateCollectionPeriods < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_periods do |t|
      t.references :owner,
                   null: false,
                   foreign_key: { to_table: :users }

      t.date :start_month, null: false
      t.date :end_month, null: false

      t.timestamps
    end

    add_index :collection_periods,
              [:owner_id, :start_month, :end_month],
              unique: true,
              name: "unique_owner_period_range"
  end
end
