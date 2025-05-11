class RemoveAllColumnToEmailSubscriptions < ActiveRecord::Migration[7.2]
  def change
    remove_column :email_subscriptions, :all
  end
end
