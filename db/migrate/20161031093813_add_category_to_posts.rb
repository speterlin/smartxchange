class AddCategoryToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :category, :string
    change_column :posts, :category, :string, null: false
  end
end
