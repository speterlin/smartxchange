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
  # probably refactor, helper files in model file
  include UsersHelper
  include PostsHelper
  include Taggable

  validates_presence_of :content, :owner, :commentable
  validates :content, length: {minimum: 5, maximum: 255}

  belongs_to :owner, class_name: 'User'
  belongs_to :commentable, polymorphic: true, touch: true
  # only doing has_one notification here because can't delete vote or message, no index on sourceable since only called here which is very rare
  has_many :notifications, as: :sourceable, dependent: :destroy

  after_create :add_or_update_owned_tags

  before_update :add_or_update_owned_tags, if: :content_present_and_changed?

  before_destroy :remove_owned_tags

  default_scope -> { order(created_at: :asc) }

  def timestamp
    created_at.strftime('%H:%M:%S %d %B %Y')
  end

end
