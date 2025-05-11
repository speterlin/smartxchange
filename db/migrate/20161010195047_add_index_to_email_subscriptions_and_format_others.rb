class AddIndexToEmailSubscriptionsAndFormatOthers < ActiveRecord::Migration[7.2]
  def change
    change_column :votes, :owner_id, :integer, null: false
    add_index :reads, [:user_id, :readable_type, :readable_id], unique: true
    change_column :reads, :readable_type, :string, null: false
    change_column :reads, :readable_id, :integer, null: false
    add_index :notifications, [:sourceable_type, :sourceable_id]
    remove_index :notifications, :notifiable_type
    change_column :notifications, :notified_id, :integer, null: false
    change_column :notifications, :notifier_id, :integer, null: false
    change_column :notifications, :notifiable_type, :string, null: false
    change_column :notifications, :notifiable_id, :integer, null: false
    change_column :notifications, :sourceable_type, :string, null: false
    change_column :notifications, :sourceable_id, :integer, null: false
    change_column :messages, :sender_id, :integer, null: false
    change_column :messages, :chat_room_id, :integer, null: false
    change_column :messages, :body, :text, null: false
    add_index :messages, :sender_id
    change_column :follows, :followable_type, :string, null: false
    change_column :follows, :followable_id, :integer, null: false
    add_index :email_subscriptions, :user_id, unique: true
    change_column :chat_rooms, :initiator_id, :integer, null: false
    change_column :chat_rooms, :recipient_id, :integer, null: false
    change_column :chat_rooms, :title, :string, null: false
    add_index :boards, :title, unique: true
  end
end
