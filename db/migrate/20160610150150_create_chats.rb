class CreateChats < ActiveRecord::Migration[7.2]
  def change
    create_table :chats do |t|
      t.integer :sender_id
      t.integer :recipient_id

      t.timestamps null: false
    end

    add_index :chats, :sender_id
    add_index :chats, :recipient_id
  end
end
