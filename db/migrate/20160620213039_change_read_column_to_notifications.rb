class ChangeReadColumnToNotifications < ActiveRecord::Migration[7.2]
  def change
    change_column :notifications, :read, :boolean, null: false, default: 'false'
  end
end
