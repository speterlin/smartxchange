class AddIndexToNameToUsers < ActiveRecord::Migration[7.2]
  def change
    add_index :users, :name, unique: true
  end
end
