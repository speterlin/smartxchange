class AddSubscriptionToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :subscription, :boolean, null: false, default: true
  end
end
