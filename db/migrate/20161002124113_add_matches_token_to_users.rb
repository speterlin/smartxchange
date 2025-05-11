class AddMatchesTokenToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :matches_token, :string
    add_column :users, :matches_sent_at, :datetime
  end
end
