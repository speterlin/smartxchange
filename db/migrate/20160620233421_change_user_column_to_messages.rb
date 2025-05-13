class ChangeUserColumnToMessages < ActiveRecord::Migration[7.2]
  def change
    remove_column :messages, :user_id
    # add_column :messages, :sender_id, :integer, index: true, foreign_key: true
    add_column :messages, :sender_id, :integer
    add_index :messages, :sender_id
    add_foreign_key :messages, :users, column: :sender_id
  end
end
