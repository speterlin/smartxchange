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
#

class Post < ApplicationRecord
  include Locatable

  validates_presence_of :owner, :board, :content, :category
  validates :content, length: {minimum: 5, maximum: 255}
  validates :category, inclusion: {in: ["Jobs-Offered", "Jobs-Wanted", "Interest", "Educational", "Tutoring", "Meetup", "Professional", "Other"]}

  belongs_to :owner, class_name: 'User'
  belongs_to :board, touch: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :follows, as: :followable, dependent: :destroy
  has_many :followers, through: :follows

  geocoded_by :location

  after_validation :geocode, if: :location_present_and_changed
  after_validation :lat_changed?

  default_scope -> { order(updated_at: :desc) }



  def timestamp
    created_at.strftime('%H:%M:%S %d %B %Y')
  end

end
