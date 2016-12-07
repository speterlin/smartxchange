class AddUnreadBoardToEmailSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :email_subscriptions, :unread_board, :boolean, null: false, default: true
  end
end
