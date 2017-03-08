# == Schema Information
#
# Table name: boards
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  description :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Board < ApplicationRecord
  validates_presence_of :title, :description
  validates :title, uniqueness: true, length: {minimum: 5, maximum: 50}
  validates :description, length: {minimum: 5, maximum: 600}

  has_many :posts, dependent: :destroy
  has_many :reads, as: :readable, dependent: :destroy
  has_many :readers, through: :reads, source: :user

  def to_param
    title.downcase
  end

end
