class AddInterestsArrayToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :interests, :text
  end
end
