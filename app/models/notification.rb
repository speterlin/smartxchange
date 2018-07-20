# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  read            :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notified_id     :integer          not null
#  notifier_id     :integer          not null
#  notifiable_type :string           not null
#  notifiable_id   :integer          not null
#  sourceable_type :string           not null
#  sourceable_id   :integer          not null
#

class Notification < ApplicationRecord
  # sourceable for a post is a vote, follow, comment, or post, and for a chatroom it is a message
  validates_presence_of :notified, :notifier, :notifiable, :sourceable

  belongs_to :notified, class_name: 'User'
  belongs_to :notifier, class_name: 'User'
  belongs_to :notifiable, polymorphic: true
  belongs_to :sourceable, polymorphic: true

  default_scope -> { order(created_at: :asc) }

end
