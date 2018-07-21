# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  content    :text             not null
#  owner_id   :integer          not null
#  board_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  category   :string           not null
#  location   :string
#  latitude   :float
#  longitude  :float
#  url        :string
#  image      :string
#

class Post < ApplicationRecord
  searchkick callbacks: :async, text_start: [:hashtags]
  scope :search_import, -> { includes(:users, :tags) }
  acts_as_taggable
  acts_as_taggable_on :users

  # probably refactor, don't like having helpers in model files, need posts_helper.rb because we use post_mention_create_notification in taggable concern
  include PostsHelper
  include Locatable
  include Taggable

  geocoded_by :location
  mount_uploader :image, AvatarUploader

  # maybe refactor and move this to a standard validation since want to check url before uploading image, but also want to set image before validation, could also make remove_url_and_image an after_validation call
  before_validation :upload_or_update_image, if: :url_present_and_changed?
  before_validation :remove_url_and_image, if: :url_not_present_and_changed?
  # maybe refactor, before_validation because content can change (remove invalid usertags) and don't want empty posts or comments created
  before_validation :add_or_update_owned_tags, if: :content_present_and_changed?

  validates_presence_of :content, :owner, :board, :category
  validates :content, length: {minimum: 1, maximum: 500}
  validates :category, inclusion: {in: ["Interest", "Educational", "Tutoring", "Meetup", "Professional", "Other"]}, if: -> { board.id != 2 }
  validates :category, inclusion: {in: ["Jobs-Offered", "Jobs-Wanted"]}, if: -> { board.id == 2 }
  validates_uniqueness_of :url, scope: :board_id, unless: -> { url.blank? }
  # maybe refactor: ?: to avoid capturing extra groups, if refactor need to update posts_controller.rb#add_or_update_url - a little redundant checking here since scanning for it in this method, taken from this site: https://forums.asp.net/t/1761988.aspx?Regular+expression+for+Validating+URL+with+or+without+http
  validates :url, length: {maximum: 255 }, format: {:with => /(?:https?\:\/\/)?(?:www\.)?(?:[-a-z0-9]+\.)+[-a-z0-9]+/i}, if: :url_present_and_changed?
  validates :image, file_size: { less_than_or_equal_to: 5.megabytes }

  after_validation :geocode, if: :location_present_and_changed?
  after_validation :remove_location, if: :location_not_present_and_changed?
  after_validation :error_and_remove_location, if: [:location_present_and_changed?, :latitude_unchanged?]

  before_update :notify_usertag_mentions, if: [:content_present_and_changed?, :usertags_present?]
  # needs to be called after record here and in comment.rb is created because need sourceable record to persist before validation in notification.rb
  after_create :notify_usertag_mentions, if: :usertags_present?

  belongs_to :owner, class_name: 'User'
  belongs_to :board, touch: true
  # dependent: :delete_all because of before_destroy callback in comment.rb which will add tags to a now non-existent post unless we use this to avoid invoking any callbacks in the child relation
  has_many :comments, as: :commentable, dependent: :delete_all
  # dependent: :delete_all here and :follows to avoid invoking dependent: :destroy on :sourced_notifications which is redundant
  has_many :votes, as: :votable, dependent: :delete_all
  has_many :follows, as: :followable, dependent: :delete_all
  has_many :followers, through: :follows
  # maybe refactor, can use dependent: :delete_all here to be quicker, but not so much speed increase and not a very important speed increase
  has_many :notifications, as: :notifiable, dependent: :destroy
  # maybe refactor, dependent: :destroy redundant here, if all of post's notifications are destroyed, all of its notification with source as itself will already be deleted
  has_many :sourced_notifications, as: :sourceable, class_name: 'Notification', dependent: :destroy

  default_scope -> { order(updated_at: :desc) }

  def timestamp
    created_at.strftime('%H:%M:%S %d %B %Y')
  end

  def upload_or_update_image
    og = OpenGraph.new(self.url)
    # Maybe refactor, assign_attributes is same as update_attributes but doesn't save
    og.images.blank? ? self.assign_attributes(remove_image: true) : self.remote_image_url = og.images.first
  end

  # not using usertags for search at the moment, maybe refactor
  def search_data
    {
      usertags: "#{users.map(&:name).join(" ")}",
      hashtags: "#{tags.map(&:name).join(" ")}"
    }
  end

  protected

  def url_present_and_changed?
    return true if (self.url.present? && self.url_changed?)
    false
  end

  def url_not_present_and_changed?
    return true if (!self.url.present? && self.url_changed?)
    false
  end

  # maybe make a concern like locatable and include methods like remove_image since used here and post
  def remove_url_and_image
    self.url = nil
    # maybe refactor, repeat code here and in upload_or_update_image
    self.assign_attributes(remove_image: true)
  end

end
