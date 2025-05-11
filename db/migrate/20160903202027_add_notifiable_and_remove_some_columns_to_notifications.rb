class AddNotifiableAndRemoveSomeColumnsToNotifications < ActiveRecord::Migration[7.2]
  def change
    remove_column :notifications, :message_id
    remove_column :notifications, :chat_room_id
    add_column :notifications, :notifiable_type, :string
    add_column :notifications, :notifiable_id, :integer
  end
end
