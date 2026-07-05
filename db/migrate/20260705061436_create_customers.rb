class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :phone_e164, null: false
      t.string :email
      t.string :tier, null: false, default: "standard"
      t.text :notes

      t.timestamps
    end

    add_index :customers, :phone_e164, unique: true
  end
end
