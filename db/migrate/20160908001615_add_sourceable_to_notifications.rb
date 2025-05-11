class AddSourceableToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :sourceable_type, :string
    add_column :notifications, :sourceable_id, :integer
  end
end
