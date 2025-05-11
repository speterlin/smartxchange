class AddOwnerToVotes < ActiveRecord::Migration[7.2]
  def change
    add_column :votes, :owner_id, :integer
  end
end
