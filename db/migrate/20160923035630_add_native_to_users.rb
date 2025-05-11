class AddNativeToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :nationality, :string
  end
end
