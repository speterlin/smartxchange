class ChangeColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    # remove_column :users, :name
    change_column :users, :name, :string, null: false, default: 'User'
    change_column :users, :age, :integer, null: false, default: 25
    change_column :users, :language, :string, null: false, default: 'Spanish'
    change_column :users, :language_level, :integer, null: false, default: 5
    change_column :users, :active, :boolean, null: false, default: 'false'
  end
end
