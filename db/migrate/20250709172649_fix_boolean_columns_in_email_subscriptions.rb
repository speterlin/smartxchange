class FixBooleanColumnsInEmailSubscriptions < ActiveRecord::Migration[7.2]
  def up
    # Step 1: Add temporary boolean columns
    add_column :email_subscriptions, :weekly_notifications_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :monthly_update_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :language_matches_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :notify_match_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :new_conversation_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :new_message_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :peer_review_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :notify_review_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :unread_board_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :unread_jobs_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :new_post_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :unread_materials_tmp, :boolean, default: true, null: false
    add_column :email_subscriptions, :related_material_tmp, :boolean, default: true, null: false

    # Step 2: Migrate data with clean casting
    EmailSubscription.reset_column_information
    EmailSubscription.find_each do |record|
      record.update_columns(
        weekly_notifications_tmp: ActiveModel::Type::Boolean.new.cast(record.weekly_notifications),
        monthly_update_tmp: ActiveModel::Type::Boolean.new.cast(record.monthly_update),
        language_matches_tmp: ActiveModel::Type::Boolean.new.cast(record.language_matches),
        notify_match_tmp: ActiveModel::Type::Boolean.new.cast(record.notify_match),
        new_conversation_tmp: ActiveModel::Type::Boolean.new.cast(record.new_conversation),
        new_message_tmp: ActiveModel::Type::Boolean.new.cast(record.new_message),
        peer_review_tmp: ActiveModel::Type::Boolean.new.cast(record.peer_review),
        notify_review_tmp: ActiveModel::Type::Boolean.new.cast(record.notify_review),
        unread_board_tmp: ActiveModel::Type::Boolean.new.cast(record.unread_board),
        unread_jobs_tmp: ActiveModel::Type::Boolean.new.cast(record.unread_jobs),
        new_post_tmp: ActiveModel::Type::Boolean.new.cast(record.new_post),
        unread_materials_tmp: ActiveModel::Type::Boolean.new.cast(record.unread_materials),
        related_material_tmp: ActiveModel::Type::Boolean.new.cast(record.related_material)
      )
    end

    # Step 3: Remove old columns
    remove_column :email_subscriptions, :weekly_notifications
    remove_column :email_subscriptions, :monthly_update
    remove_column :email_subscriptions, :language_matches
    remove_column :email_subscriptions, :notify_match
    remove_column :email_subscriptions, :new_conversation
    remove_column :email_subscriptions, :new_message
    remove_column :email_subscriptions, :peer_review
    remove_column :email_subscriptions, :notify_review
    remove_column :email_subscriptions, :unread_board
    remove_column :email_subscriptions, :unread_jobs
    remove_column :email_subscriptions, :new_post
    remove_column :email_subscriptions, :unread_materials
    remove_column :email_subscriptions, :related_material

    # Step 4: Rename temp columns
    rename_column :email_subscriptions, :weekly_notifications_tmp, :weekly_notifications
    rename_column :email_subscriptions, :monthly_update_tmp, :monthly_update
    rename_column :email_subscriptions, :language_matches_tmp, :language_matches
    rename_column :email_subscriptions, :notify_match_tmp, :notify_match
    rename_column :email_subscriptions, :new_conversation_tmp, :new_conversation
    rename_column :email_subscriptions, :new_message_tmp, :new_message
    rename_column :email_subscriptions, :peer_review_tmp, :peer_review
    rename_column :email_subscriptions, :notify_review_tmp, :notify_review
    rename_column :email_subscriptions, :unread_board_tmp, :unread_board
    rename_column :email_subscriptions, :unread_jobs_tmp, :unread_jobs
    rename_column :email_subscriptions, :new_post_tmp, :new_post
    rename_column :email_subscriptions, :unread_materials_tmp, :unread_materials
    rename_column :email_subscriptions, :related_material_tmp, :related_material
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration is not reversible"
  end
end
