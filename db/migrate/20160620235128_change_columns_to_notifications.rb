class ChangeColumnsToNotifications < ActiveRecord::Migration[7.2]
  def change
    remove_reference :notifications, :user
    # remove_reference :notifications, :subscribed_user
    add_reference :notifications, :user, index: { name: "notified_id" }, foreign_key: true
    add_reference :notifications, :user, index: { name: "notifier_id" }, foreign_key: true
  end
end
