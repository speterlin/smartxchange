class AddRelatedMaterialToEmailSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :email_subscriptions, :related_material, :boolean, null: false, default: true
  end
end
