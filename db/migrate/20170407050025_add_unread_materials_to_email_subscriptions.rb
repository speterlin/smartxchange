class AddUnreadMaterialsToEmailSubscriptions < ActiveRecord::Migration[7.2]
  def change
    add_column :email_subscriptions, :unread_materials, :boolean, null: false, default: true
  end
end
