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
    # removed in upcoming migration db/migrate/20160620235128_change_columns_to_notifications.rb but keeping, here and below foreign keys already established because of incomplete migration
    if table_exists?(:notifications) && foreign_key_exists?(:notifications, name: "fk_rails_b080fb4855")
      puts "Foreign key already exists"
    else
      add_foreign_key :notifications, :users
    end
    # add_foreign_key :notifications, :users, column: :subscribed_user_id
    if table_exists?(:notifications) && foreign_key_exists?(:notifications, name: "fk_rails_0d5aac9e45")
      puts "Foreign key already exists"
    else
      add_foreign_key :notifications, :chats
    end
  end
end
