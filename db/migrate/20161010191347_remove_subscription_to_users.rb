class RemoveSubscriptionToUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :subscription
  end
end
