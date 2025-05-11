class DeleteColumnToMessages < ActiveRecord::Migration[7.2]
  def change
    remove_column :messages, :chat_id
  end
end
