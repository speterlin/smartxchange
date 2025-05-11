class AddBirthdateToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :birthdate, :date
  end
end
