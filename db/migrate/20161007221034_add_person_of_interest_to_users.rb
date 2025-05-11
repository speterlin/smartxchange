class AddPersonOfInterestToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :person_of_interest, :boolean, null: false, default: false
  end
end
