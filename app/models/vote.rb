# == Schema Information
#
# Table name: votes
#
#  id           :integer          not null, primary key
#  value        :integer          not null
#  votable_type :string           not null
#  votable_id   :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :integer          not null
#

class Vote < ApplicationRecord
  validates_presence_of :value, :votable, :owner
  validates :value, inclusion: { in: [1,-1] }

  belongs_to :votable, polymorphic: true, touch: true
  belongs_to :owner, class_name: 'User'

  has_many :sourced_notifications, as: :sourceable, class_name: 'Notification', dependent: :destroy

end
