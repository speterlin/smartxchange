class ChangeDefaultValuesToUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :title, :string, null: false, default: 'Finding inner peace'
    change_column :users, :name, :string, null: false, default: 'Buddha'
  end
end
