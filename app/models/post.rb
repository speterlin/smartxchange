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

  validates_presence_of :content, :owner, :board, :category
  validates :content, length: {minimum: 5, maximum: 500}
  validates :category, inclusion: {in: ["Jobs-Offered", "Jobs-Wanted", "Interest", "Educational", "Tutoring", "Meetup", "Professional", "Other"]}
  validates_uniqueness_of :url, scope: :board_id, unless: 'url.blank?'
  # maybe refactor returns 2 match groups, alternative: (^https?\:\/\/www\.([-a-z0-9]+\.)+[-a-z0-9]+.*), taken from this site: https://forums.asp.net/t/1761988.aspx?Regular+expression+for+Validating+URL+with+or+without+http
  validates :url, length: {maximum: 255 }, format: {:with => /(^(https?\:\/\/)(www\.)?(?:[-a-z0-9]+\.)*[-a-z0-9]+.*)/i}, if: :url_present_and_changed?
  validates :image, file_size: { less_than_or_equal_to: 5.megabytes }
  mount_uploader :image, AvatarUploader

  belongs_to :owner, class_name: 'User'
  belongs_to :board, touch: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :follows, as: :followable, dependent: :destroy
  has_many :followers, through: :follows

  geocoded_by :location

  before_validation :upload_or_update_image, if: :url_present_and_changed?
  after_validation :geocode, if: :location_present_and_changed?
  after_validation :lat_changed?

  default_scope -> { order(updated_at: :desc) }

  def timestamp
    updated_at.strftime('%H:%M:%S %d %B %Y')
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

end
