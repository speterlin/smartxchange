class AddColumnToMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages, :chat_room_id, :integer
    add_index :messages, :chat_room_id
  end
end
