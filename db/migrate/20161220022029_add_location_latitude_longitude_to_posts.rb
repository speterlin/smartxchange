class AddLocationLatitudeLongitudeToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :location, :string
    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float
  end
end
