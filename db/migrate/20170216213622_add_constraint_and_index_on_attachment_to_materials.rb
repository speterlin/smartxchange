class AddConstraintAndIndexOnAttachmentToMaterials < ActiveRecord::Migration[7.2]
  def change
    change_column :materials, :attachment, :string, null: false
    remove_index :materials, [:name, :owner_id]
    add_index :materials, [:name, :attachment, :owner_id], unique: true
  end
end
