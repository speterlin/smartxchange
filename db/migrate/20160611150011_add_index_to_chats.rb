class AddIndexToChats < ActiveRecord::Migration[7.2]
  def change
    add_index :chats, :created_at
  end
end
