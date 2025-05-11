class AddImageToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :image, :string
  end
end
