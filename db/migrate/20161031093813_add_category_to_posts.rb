class AddCategoryToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :category, :string
  end
end
