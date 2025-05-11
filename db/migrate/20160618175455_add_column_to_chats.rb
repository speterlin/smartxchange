class AddColumnToChats < ActiveRecord::Migration[7.2]
  def change
    add_column :chats, :unread_messages, :integer, null: false, default: 0
  end
end
