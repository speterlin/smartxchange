class ChangeIdentifierToNotifications < ActiveRecord::Migration[7.2]
  def change
    remove_column :notifications, :identifier
    add_column :notifications, :message_id, :integer
  end
end
