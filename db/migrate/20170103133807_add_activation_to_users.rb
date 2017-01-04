class AddActivationToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :activation_token, :string
    add_column :users, :activated, :boolean, default: false
  end
end
