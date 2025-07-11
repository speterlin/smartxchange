# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_07_09_172649) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "basic_profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "maiden_name"
    t.string "formatted_name"
    t.string "headline"
    t.string "location"
    t.string "industry"
    t.string "summary"
    t.string "specialties"
    t.string "picture_url"
    t.string "public_profile_url"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "boards", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["title"], name: "index_boards_on_title", unique: true
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "initiator_id", null: false
    t.integer "recipient_id", null: false
    t.index ["initiator_id"], name: "index_chat_rooms_on_initiator_id"
    t.index ["recipient_id"], name: "index_chat_rooms_on_recipient_id"
    t.index ["updated_at"], name: "index_chat_rooms_on_updated_at"
  end

  create_table "chats", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["created_at"], name: "index_chats_on_created_at"
    t.index ["recipient_id"], name: "index_chats_on_recipient_id"
    t.index ["sender_id"], name: "index_chats_on_sender_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content", null: false
    t.integer "owner_id", null: false
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["owner_id"], name: "index_comments_on_owner_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "educations", force: :cascade do |t|
    t.string "school_name"
    t.string "field_of_study"
    t.date "start_date"
    t.date "end_date"
    t.string "degree"
    t.string "activities"
    t.string "notes"
    t.integer "full_profile_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "email_subscriptions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "weekly_notifications", default: true, null: false
    t.boolean "monthly_update", default: true, null: false
    t.boolean "language_matches", default: true, null: false
    t.boolean "notify_match", default: true, null: false
    t.boolean "new_conversation", default: true, null: false
    t.boolean "new_message", default: true, null: false
    t.boolean "peer_review", default: true, null: false
    t.boolean "notify_review", default: true, null: false
    t.boolean "unread_board", default: true, null: false
    t.boolean "unread_jobs", default: true, null: false
    t.boolean "new_post", default: true, null: false
    t.boolean "unread_materials", default: true, null: false
    t.boolean "related_material", default: true, null: false
    t.index ["user_id"], name: "index_email_subscriptions_on_user_id", unique: true
  end

  create_table "follows", force: :cascade do |t|
    t.integer "follower_id", null: false
    t.string "followable_type", null: false
    t.integer "followable_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id"
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "full_profiles", force: :cascade do |t|
    t.string "associations"
    t.string "honors"
    t.string "interests"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "linkedin_oauth_settings", force: :cascade do |t|
    t.string "atoken"
    t.string "asecret"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "linkedins", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "public_url"
    t.string "industry"
    t.string "summary"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_linkedins_on_user_id", unique: true
  end

  create_table "materials", force: :cascade do |t|
    t.string "name", null: false
    t.string "attachment", null: false
    t.integer "owner_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "language", default: "Spanish", null: false
    t.integer "language_level", default: 3, null: false
    t.index ["attachment", "owner_id"], name: "index_materials_on_attachment_and_owner_id", unique: true
    t.index ["name", "owner_id"], name: "index_materials_on_name_and_owner_id", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "sender_id", null: false
    t.integer "chat_room_id", null: false
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "notified_id", null: false
    t.integer "notifier_id", null: false
    t.string "notifiable_type", null: false
    t.integer "notifiable_id", null: false
    t.string "sourceable_type", null: false
    t.integer "sourceable_id", null: false
    t.boolean "read", default: false, null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["notified_id"], name: "index_notifications_on_notified_id"
    t.index ["sourceable_type", "sourceable_id"], name: "index_notifications_on_sourceable_type_and_sourceable_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "classification", null: false
    t.string "description", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "price", precision: 8, scale: 2
    t.index ["classification"], name: "index_packages_on_classification", unique: true
  end

  create_table "positions", force: :cascade do |t|
    t.string "title"
    t.string "summary"
    t.date "start_date"
    t.date "end_date"
    t.boolean "is_current"
    t.string "company"
    t.integer "full_profile_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "posts", force: :cascade do |t|
    t.text "content", null: false
    t.integer "owner_id", null: false
    t.integer "board_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "category", null: false
    t.string "location"
    t.float "latitude"
    t.float "longitude"
    t.string "url"
    t.string "image"
    t.index ["owner_id"], name: "index_posts_on_owner_id"
    t.index ["updated_at"], name: "index_posts_on_updated_at"
  end

  create_table "purchases", force: :cascade do |t|
    t.integer "buyer_id", null: false
    t.integer "package_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["buyer_id", "package_id"], name: "index_purchases_on_buyer_id_and_package_id", unique: true
    t.index ["buyer_id"], name: "index_purchases_on_buyer_id"
  end

  create_table "reads", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "readable_type", null: false
    t.integer "readable_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["readable_type", "readable_id"], name: "index_reads_on_readable_type_and_readable_id"
    t.index ["user_id", "readable_type", "readable_id"], name: "index_reads_on_user_id_and_readable_type_and_readable_id", unique: true
    t.index ["user_id"], name: "index_reads_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "reviewer_id", null: false
    t.string "reviewable_type", null: false
    t.integer "reviewable_id", null: false
    t.integer "chat_room_id", null: false
    t.string "language", null: false
    t.integer "language_level", null: false
    t.text "comment"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["chat_room_id", "reviewer_id"], name: "index_reviews_on_chat_room_id_and_reviewer_id", unique: true
    t.index ["chat_room_id"], name: "index_reviews_on_chat_room_id"
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable_type_and_reviewable_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", default: "New User", null: false
    t.integer "age", default: 25, null: false
    t.string "language", default: "Spanish", null: false
    t.integer "language_level", default: 3, null: false
    t.string "password_digest", null: false
    t.string "session_token", null: false
    t.string "image"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title", default: "Please fill in your profession", null: false
    t.string "provider"
    t.string "uid"
    t.string "location"
    t.float "latitude"
    t.float "longitude"
    t.string "nationality", default: "Spanish", null: false
    t.string "matches_token"
    t.datetime "matches_sent_at", precision: nil
    t.string "braintree_customer_id"
    t.text "interests"
    t.string "activation_token"
    t.string "ip_address"
    t.date "birthdate"
    t.boolean "tutor", default: false
    t.boolean "active", default: false, null: false
    t.boolean "person_of_interest", default: false, null: false
    t.boolean "activated", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["session_token"], name: "index_users_on_session_token"
  end

  create_table "votes", force: :cascade do |t|
    t.integer "value", limit: 1, null: false
    t.string "votable_type", null: false
    t.integer "votable_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "owner_id", null: false
    t.index ["owner_id"], name: "index_votes_on_owner_id"
    t.index ["votable_type", "votable_id"], name: "index_votes_on_votable_type_and_votable_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
