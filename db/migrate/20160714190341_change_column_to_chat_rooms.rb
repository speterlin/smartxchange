class ChangeColumnToChatRooms < ActiveRecord::Migration[7.2]
  def change
    remove_column :notifications, :chat_id
    add_column :notifications, :chat_room_id, :integer
  end
end
