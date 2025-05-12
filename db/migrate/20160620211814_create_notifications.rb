class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :user, index: true, foreign_key: true
      # t.references :subscribed_user, index: true, foreign_key: true
      t.references :chat, index: true, foreign_key: true
      t.integer :identifier #id of the message
      t.boolean :read

      t.timestamps null: false
    end
    add_foreign_key :notifications, :users
    # add_foreign_key :notifications, :users, column: :subscribed_user_id
    add_foreign_key :notifications, :chats
  end
end
