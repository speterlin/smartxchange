# == Schema Information
#
# Table name: chat_rooms
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  initiator_id :integer          not null
#  recipient_id :integer          not null
#

class ChatRoom < ApplicationRecord
  validates_presence_of :initiator, :recipient, :title
  validates_inclusion_of :title, in: User::LANGUAGES
  # maybe remove this validation only used when creating chat rooms from command line
  validate :unique_chat_room?
  validate :person_of_interest_or_chat_bot_or_tutor_and_not_premium_or_admin?

  belongs_to :initiator, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  # dependent: :delete_all to avoid invoking dependent: :destroy on :sourced_notifications of message.rb which is redundant
  has_many :messages, dependent: :delete_all
  has_many :notifications, as: :notifiable, dependent: :destroy
  # no dependent destroy want review to persist even if chat_room is deleted
  has_many :user_reviews, foreign_key: :chat_room_id, class_name: 'Review'

  default_scope -> { order(updated_at: :desc) }

  # to check for any existing chats initiated by you or with you
  scope :involving, -> (user) do
    where("chat_rooms.initiator_id =? OR chat_rooms.recipient_id =?",user.id,user.id)
  end

  # to check to see if there any existing chats between you and the potential recepient
  scope :between, -> (initiator_id, recipient_id, title) do
    where("((chat_rooms.initiator_id = ? AND chat_rooms.recipient_id =?) OR (chat_rooms.initiator_id = ? AND chat_rooms.recipient_id =?)) AND chat_rooms.title = ?", initiator_id, recipient_id, recipient_id, initiator_id, title)
  end

  def person_of_interest_or_chat_bot_or_tutor_and_not_premium_or_admin?
    initiator = self.initiator
    recipient = self.recipient
    if (recipient.person_of_interest? || recipient.chat_bot? || recipient.tutor?) && !initiator.premium_or_admin?
      errors.add(:recipient_id, "is a Person of Interest, Chatbot, or Tutor, <a href=\"/about#premium\">Premium</a> membership required for Initiator")
    end
  end

  protected

  def unique_chat_room?
    if ChatRoom.between(self.initiator_id, self.recipient_id, self.title).any?
      errors.add(:title, "conversation exists between these 2 users")
    end
  end

end
