class CreateMaterials < ActiveRecord::Migration[7.2]
  def change
    create_table :materials do |t|
      t.string :name, null: false
      t.string :attachment
      t.integer :owner_id, null: false

      t.timestamps
    end
    add_index :materials, [:name, :owner_id], unique: true
  end
end
