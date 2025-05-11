class AddLocationLatitudeLongitudeToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :location, :string
    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float
  end
end
