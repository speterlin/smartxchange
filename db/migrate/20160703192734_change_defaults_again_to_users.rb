class ChangeDefaultsAgainToUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :title, :string, null: false, default: 'Please fill in your profession'
    change_column :users, :name, :string, null: false, default: 'New User'
    change_column :users, :active, :boolean, null: false, default: 'false'
  end
end
