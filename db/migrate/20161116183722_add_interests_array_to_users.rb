class AddInterestsArrayToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :interests, :text
  end
end
