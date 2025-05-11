class ChangeDefaultsInColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :title, :string, null: false
    change_column :users, :name, :string, null: false
    change_column :users, :active, :boolean, null: false, default: 'true'
    change_column :users, :language_level, :integer, null: false, default: 3
  end
end
