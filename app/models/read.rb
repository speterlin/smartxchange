# == Schema Information
#
# Table name: reads
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  readable_type :string           not null
#  readable_id   :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Read < ApplicationRecord
  validates_presence_of :user, :readable
  validates_uniqueness_of :user_id, :scope => [:readable_type, :readable_id]

  belongs_to :user
  belongs_to :readable, polymorphic: true
  
end
