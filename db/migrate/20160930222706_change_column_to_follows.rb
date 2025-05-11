class ChangeColumnToFollows < ActiveRecord::Migration[7.2]
  def change
    change_column :follows, :follower_id, :integer, null: false
  end
end
