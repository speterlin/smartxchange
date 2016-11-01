class AddNotNullConstraintToCategoryToPosts < ActiveRecord::Migration[5.0]
  def change
    change_column :posts, :category, :string, null: false
  end
end
