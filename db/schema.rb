# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_12_060013) do
  create_table "collection_periods", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.date "start_month", null: false
    t.date "end_month", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "start_month", "end_month"], name: "unique_owner_period_range", unique: true
    t.index ["owner_id"], name: "index_collection_periods_on_owner_id"
  end

  create_table "installments", force: :cascade do |t|
    t.integer "member_id", null: false
    t.date "month", null: false
    t.date "due_date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id", "month"], name: "unique_member_installment_month", unique: true
    t.index ["member_id"], name: "index_installments_on_member_id"
  end

  create_table "members", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.string "member_id", limit: 20, null: false
    t.string "name", limit: 150, null: false
    t.string "phone", limit: 15, null: false
    t.decimal "monthly_amount", precision: 10, scale: 2, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "member_id"], name: "unique_owner_member_id", unique: true
    t.index ["owner_id"], name: "index_members_on_owner_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "installment_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "payment_date", null: false
    t.string "reference", limit: 100, default: "", null: false
    t.integer "recorded_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["installment_id"], name: "index_payments_on_installment_id", unique: true
    t.index ["recorded_by_id"], name: "index_payments_on_recorded_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "collection_periods", "users", column: "owner_id"
  add_foreign_key "installments", "members"
  add_foreign_key "members", "users", column: "owner_id"
  add_foreign_key "payments", "installments"
  add_foreign_key "payments", "users", column: "recorded_by_id", on_delete: :nullify
end
