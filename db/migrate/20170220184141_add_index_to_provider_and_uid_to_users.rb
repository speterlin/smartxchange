class AddIndexToProviderAndUidToUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :users, [:provider, :uid], unique: true
  end
end
