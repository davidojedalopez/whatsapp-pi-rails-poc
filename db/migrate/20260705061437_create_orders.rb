class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :external_id, null: false
      t.string :status, null: false
      t.integer :total_cents, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.text :summary

      t.timestamps
    end

    add_index :orders, :external_id, unique: true
  end
end
