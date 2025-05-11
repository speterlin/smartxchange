class AddColumnsToChatRooms < ActiveRecord::Migration[7.2]
  def change
    remove_column :chat_rooms, :user_id
    add_column :chat_rooms, :initiator_id, :integer
    add_column :chat_rooms, :recipient_id, :integer
  end
end
