# == Schema Information
#
# Table name: follows
#
#  id              :integer          not null, primary key
#  follower_id     :integer          not null
#  followable_type :string           not null
#  followable_id   :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Follow < ApplicationRecord
  validates_presence_of :follower, :followable
  # wasn't able to add this validation to database, exceeds 62 character limit
  validates_uniqueness_of :follower_id, scope: [:followable_type, :followable_id]

  before_save :ensure_post_owner_not_follower

  belongs_to :followable, polymorphic: true, touch: true
  belongs_to :follower, class_name: 'User'
  # to make notification checks easier
  belongs_to :owner, :foreign_key => :follower_id, class_name: 'User'

  private

  def ensure_post_owner_not_follower
    # for now follawble_type will always be Post, just extra precaution
    raise "Post owner can not be follower!" if self.followable_type == 'Post' && self.followable.owner == self.follower
  end

end
