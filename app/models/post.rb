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
  include Locatable
  # probably refactor, don't like having helpers in model files
  include UsersHelper
  include PostsHelper
  include Taggable

  geocoded_by :location
  mount_uploader :image, AvatarUploader
  acts_as_taggable
  acts_as_taggable_on :users

  # maybe refactor and move this to a standard validation since want to check url before uploading image, but also want to set image before validation, could also make remove_url_and_image an after_validation call
  before_validation :upload_or_update_image, if: :url_present_and_changed?
  before_validation :remove_url_and_image, if: :url_not_present_and_changed?

  validates_presence_of :content, :owner, :board, :category
  validates :content, length: {minimum: 5, maximum: 500}
  validates :category, inclusion: {in: ["Interest", "Educational", "Tutoring", "Meetup", "Professional", "Other"]}, if: 'board.id != 2'
  validates :category, inclusion: {in: ["Jobs-Offered", "Jobs-Wanted"]}, if: 'board.id == 2'
  validates_uniqueness_of :url, scope: :board_id, unless: 'url.blank?'
  # maybe refactor: ?: to avoid capturing extra groups, taken from this site: https://forums.asp.net/t/1761988.aspx?Regular+expression+for+Validating+URL+with+or+without+http
  validates :url, length: {maximum: 255 }, format: {:with => /(^(?:https?\:\/\/)(?:www\.)?(?:[-a-z0-9]+\.)+[-a-z0-9]+.*)/i}, if: :url_present_and_changed?
  validates :image, file_size: { less_than_or_equal_to: 5.megabytes }

  after_validation :geocode, if: :location_present_and_changed?
  after_validation :remove_location, if: :location_not_present_and_changed?
  after_validation :error_and_remove_location, if: :location_present_and_changed_and_latitude_unchanged?

  after_create :update_owned_tags

  before_update :update_owned_tags, if: :content_present_and_changed?

  belongs_to :owner, class_name: 'User'
  belongs_to :board, touch: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :follows, as: :followable, dependent: :destroy
  has_many :followers, through: :follows

  default_scope -> { order(updated_at: :desc) }

  def timestamp
    created_at.strftime('%H:%M:%S %d %B %Y')
  end

  def upload_or_update_image
    og = OpenGraph.new(self.url)
    # Maybe refactor, assign_attributes is same as update_attributes but doesn't save
    og.images.blank? ? self.assign_attributes(remove_image: true) : self.remote_image_url = og.images.first
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
