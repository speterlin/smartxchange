# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  body         :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sender_id    :integer          not null
#  chat_room_id :integer          not null
#

class Message < ApplicationRecord
  validates_presence_of :chat_room, :sender, :body
  validates :body, length: {minimum: 1, maximum: 500}

  belongs_to :sender, class_name: 'User'
  belongs_to :chat_room, touch: true

  # maybe refactor / take out not necessary since default is asc
  default_scope -> { order(created_at: :asc) }

  after_create :notify_recipient?
  after_create :send_peer_review?

  # after_create_commit { SendEmailJob.perform_later(self) }

  def timestamp
    created_at.strftime('%H:%M:%S %d %B %Y')
  end

  protected

  def notify_recipient?
    if self.chat_room.updated_at < 1.hour.ago
      UserMailer.delay(run_at: 30.seconds.from_now).new_message(self)
    end
  end

  def send_peer_review?
    # send peer review email after every 100 messages in conversation
    limit = 100
    if (self.chat_room.messages.size % limit == 0 ) && (self.chat_room.messages.size / limit != 0)
      UserMailer.delay(run_at: 30.seconds.from_now).peer_review(self.chat_room.initiator, self.chat_room.recipient, self.chat_room)
      UserMailer.delay(run_at: 30.seconds.from_now).peer_review(self.chat_room.recipient, self.chat_room.initiator, self.chat_room)
    end
  end

end
