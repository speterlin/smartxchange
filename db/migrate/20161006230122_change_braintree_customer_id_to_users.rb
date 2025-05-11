class ChangeBraintreeCustomerIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :braintree_customer_id, :string
  end
end
