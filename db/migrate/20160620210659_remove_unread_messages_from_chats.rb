class RemoveUnreadMessagesFromChats < ActiveRecord::Migration[7.2]
  def change
    remove_column :chats, :unread_messages
  end
end
