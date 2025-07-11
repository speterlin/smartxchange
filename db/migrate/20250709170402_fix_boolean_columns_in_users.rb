class FixBooleanColumnsInUsers < ActiveRecord::Migration[7.2]
  def up
    # Step 1: Add temporary columns
    add_column :users, :active_tmp, :boolean, default: false, null: false
    add_column :users, :person_of_interest_tmp, :boolean, default: false, null: false
    add_column :users, :activated_tmp, :boolean, default: false

    # Step 2: Copy cleaned values
    User.reset_column_information
    User.find_each do |user|
      user.update_columns(
        active_tmp: ActiveModel::Type::Boolean.new.cast(user.active),
        person_of_interest_tmp: ActiveModel::Type::Boolean.new.cast(user.person_of_interest),
        activated_tmp: ActiveModel::Type::Boolean.new.cast(user.activated)
      )
    end

    # Step 3: Remove original columns
    remove_column :users, :active
    remove_column :users, :person_of_interest
    remove_column :users, :activated

    # Step 4: Rename temp columns to original names
    rename_column :users, :active_tmp, :active
    rename_column :users, :person_of_interest_tmp, :person_of_interest
    rename_column :users, :activated_tmp, :activated
  end

  def down
    # If needed, reverse the process
    add_column :users, :active_tmp, :string, default: 'f', null: false
    add_column :users, :person_of_interest_tmp, :string, default: 'f', null: false
    add_column :users, :activated_tmp, :string, default: 'f'

    User.reset_column_information
    User.find_each do |user|
      user.update_columns(
        active_tmp: user.active ? 't' : 'f',
        person_of_interest_tmp: user.person_of_interest ? 't' : 'f',
        activated_tmp: user.activated ? 't' : 'f'
      )
    end

    remove_column :users, :active
    remove_column :users, :person_of_interest
    remove_column :users, :activated

    rename_column :users, :active_tmp, :active
    rename_column :users, :person_of_interest_tmp, :person_of_interest
    rename_column :users, :activated_tmp, :activated
  end
end
