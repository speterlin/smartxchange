class CreatePurchases < ActiveRecord::Migration[7.2]
  def change
    create_table :purchases do |t|
      t.integer :buyer_id, null: false
      t.integer :package_id, null: false

      t.timestamps
    end
    add_index :purchases, [:buyer_id, :package_id], unique: true
    add_index :purchases, :buyer_id
  end
end
