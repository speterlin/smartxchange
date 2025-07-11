class FixReadColumnTypeOnNotifications < ActiveRecord::Migration[7.2]
  def up
    # 1. Add a proper boolean column (which SQLite stores as integer)
    add_column :notifications, :read_tmp, :boolean, default: false, null: false

    # 2. Copy values from old column with proper casting
    Notification.reset_column_information
    Notification.find_each do |notification|
      value = ActiveModel::Type::Boolean.new.cast(notification.read)
      notification.update_column(:read_tmp, value)
    end

    # 3. Remove old column and rename the new one
    remove_column :notifications, :read
    rename_column :notifications, :read_tmp, :read
  end

  def down
    add_column :notifications, :read_tmp, :string, default: 'f', null: false

    Notification.reset_column_information
    Notification.find_each do |notification|
      string_value = notification.read ? 't' : 'f'
      notification.update_column(:read_tmp, string_value)
    end

    remove_column :notifications, :read
    rename_column :notifications, :read_tmp, :read
  end
end
