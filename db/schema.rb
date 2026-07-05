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

ActiveRecord::Schema[8.1].define(version: 2026_07_05_061437) do
  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.text "notes"
    t.string "phone_e164", null: false
    t.string "tier", default: "standard", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_e164"], name: "index_customers_on_phone_e164", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.integer "customer_id", null: false
    t.string "external_id", null: false
    t.string "status", null: false
    t.text "summary"
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["external_id"], name: "index_orders_on_external_id", unique: true
  end

  add_foreign_key "orders", "customers"
end
