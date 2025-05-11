class AddIndexToLinkedins < ActiveRecord::Migration[7.2]
  def change
    add_index :linkedins, :user_id, unique: true
  end
end
