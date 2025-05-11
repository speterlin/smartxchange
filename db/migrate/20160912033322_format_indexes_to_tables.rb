class FormatIndexesToTables < ActiveRecord::Migration[7.2]
  def change
    add_index :chat_rooms, :initiator_id
    add_index :chat_rooms, :recipient_id
    add_index :chat_rooms, :updated_at
    remove_index :comments, :commentable_type
    remove_index :comments, :commentable_id
    # so far this index only used a couple times in post. call
    add_index :comments, [:commentable_type, :commentable_id]
    add_index :comments, [:created_at]
    remove_index :follows, :followable_type
    remove_index :follows, :followable_id
    add_index :follows, [:followable_type, :followable_id]
    # removing this since rarely using notifier association
    remove_index :notifications, :notifier_id
    add_index :notifications, :notifiable_type
    add_index :notifications, [:notifiable_type, :notifiable_id]
    add_index :notifications, :created_at
    add_index :posts, :updated_at
    add_index :votes, :owner_id
    remove_index :votes, :votable_type
    remove_index :votes, :votable_id
    add_index :votes, [:votable_type, :votable_id]
  end
end
