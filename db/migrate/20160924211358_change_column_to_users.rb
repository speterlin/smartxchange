class ChangeColumnToUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :nationality, :string, null: false, default: "Spanish"
  end
end
