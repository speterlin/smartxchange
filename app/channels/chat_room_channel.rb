# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
# For uri encoding, URI:encode is deprecated according to stackoverflow question 6714196, probably refactor CGI out eventually
require 'cgi'
class ChatRoomChannel < ApplicationCable::Channel
  include UsersHelper
  include ChatRoomsHelper

  def subscribed
    stream_from "chat_rooms_#{params['chat_room_id']}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    # keeping bang on create method here and in chatbot response so it stops downstream processes and gives correct validation error
    message = current_user.sent_messages.create!(body: data['message'], chat_room_id: data['chat_room_id'])
    # need to refactor and implement error message here
    if message
      ActionCable.server.broadcast "chat_rooms_#{message.chat_room.id}_channel",
                                   message: render_message(message)
      chat_room_create_notification(message)
    end

    # for chatbot response, assuming chat bot is always recipient, refactor and maybe change check about current_user's message getting through
    chat_room = ChatRoom.find(data['chat_room_id'])
    # maybe refactor a lot of checks
    if chat_room.recipient.chat_bot? && message && !message.sender.chat_bot?
      response = Pandorabots::API.talk(ENV['PANDORABOTS_APP_ID'], "uktrivia", CGI.escape(message.body), "chatroom#{chat_room.id}", user_key: ENV['PANDORABOTS_USER_KEY'])
      # responds even if error (error is produced in output), may refactor later, and see if its faster to do Message.create!
      response_message = chat_room.recipient.sent_messages.create!(body: response["responses"][0], chat_room_id: chat_room.id)
      # maybe implement code for if there is an error in message creation here, like above
      if response_message
        ActionCable.server.broadcast "chat_rooms_#{chat_room.id}_channel",
                                     message: render_message(response_message)
        chat_room_create_notification(response_message)
      end
    end
  end

  private

  def render_message(message)
    MessagesController.render(partial: 'messages/message',
                              locals: { message: message, current_user: current_user})
  end

end
