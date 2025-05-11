class CreateEmailSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :email_subscriptions do |t|
      t.integer :user_id, null: false
      t.boolean :all, null: false, default: true
      t.boolean :weekly_notifications, null: false, default: true
      t.boolean :monthly_update, null: false, default: true
      t.boolean :language_matches, null: false, default: true
      t.boolean :notify_match, null: false, default: true

      t.timestamps
    end
  end
end
