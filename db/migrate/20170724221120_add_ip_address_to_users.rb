class AddIpAddressToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :ip_address, :string
  end
end
