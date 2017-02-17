class ChangeIndexToMaterials < ActiveRecord::Migration[5.0]
  def change
    remove_index :materials, [:name, :attachment, :owner_id]
    add_index :materials, [:name, :owner_id], unique: true
    add_index :materials, [:attachment, :owner_id], unique: true
  end
end
