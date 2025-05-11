class AddRelatedMaterialToEmailSubscriptions < ActiveRecord::Migration[7.2]
  def change
    add_column :email_subscriptions, :related_material, :boolean, null: false, default: true
  end
end
