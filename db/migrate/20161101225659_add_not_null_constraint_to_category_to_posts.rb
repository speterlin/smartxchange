class AddNotNullConstraintToCategoryToPosts < ActiveRecord::Migration[7.2]
  def change
    change_column :posts, :category, :string, null: false
  end
end
