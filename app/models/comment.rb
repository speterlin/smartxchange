# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text             not null
#  owner_id         :integer          not null
#  commentable_type :string           not null
#  commentable_id   :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Comment < ApplicationRecord
  # probably refactor, helper files in model file, include PostsHelpers because posts_helper.rb#post_mention_create_notification called in #notify_usertag_mentions
  include PostsHelper
  include Taggable

  before_validation :add_or_update_owned_tags, if: :content_present_and_changed?

  validates_presence_of :content, :owner, :commentable
  validates :content, length: {minimum: 1, maximum: 255}

  belongs_to :owner, class_name: 'User'
  belongs_to :commentable, polymorphic: true, touch: true

  has_many :sourced_notifications, as: :sourceable, class_name: 'Notification', dependent: :destroy

  # maybe refactor, need this even though have touch: true which just updates the updated_at attribute and disregards previous changes, only before_save here and not post.rb since post is already the tag item, better to have here after validations for comment have passed (no point in updating tags if comment not saved)
  before_save :save_tag_item, if: :content_present_and_changed?
  before_update :notify_usertag_mentions, if: [:content_present_and_changed?, :usertags_present?]
  after_create :notify_usertag_mentions, if: :usertags_present?

  before_destroy :remove_owned_tags

  default_scope -> { order(created_at: :asc) }

  def timestamp
    created_at.strftime('%H:%M:%S %d %B %Y')
  end

end
