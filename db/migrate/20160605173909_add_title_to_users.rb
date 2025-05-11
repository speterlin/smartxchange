class AddTitleToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :title, :string, null: false, default: 'Baller at Life'
  end
end
