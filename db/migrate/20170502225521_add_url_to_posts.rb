class AddUrlToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :url, :string
  end
end
