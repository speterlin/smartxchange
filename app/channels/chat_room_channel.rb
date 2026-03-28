# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
# For uri encoding, URI:encode is deprecated according to stackoverflow question 6714196, probably refactor CGI out eventually
require 'cgi'
class ChatRoomChannel < ApplicationCable::Channel
  # for using #chat_room_create_notification
  include ChatRoomsHelper

  def subscribed
    stream_from "chat_rooms_#{params['chat_room_id']}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    return unless message_limit
    # keeping bang on create method here and in chatbot response so it stops downstream processes and gives correct validation error
    message = current_user.sent_messages.create!(body: data['message'], chat_room_id: data['chat_room_id'])
    # need to refactor and implement error message here
    if message
      ActionCable.server.broadcast("chat_rooms_#{message.chat_room.id}_channel",
                                   { message: render_message(message) }) # In Rails 7.2+, broadcast now expects two arguments: the stream name and the data as a hash, but this form changed subtly.  But in Ruby 3.0+, especially 3.4.0, this breaks due to stricter keyword argument handling — you must pass a real hash.
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
        ActionCable.server.broadcast("chat_rooms_#{chat_room.id}_channel",
                                     { message: render_message(response_message) })
        chat_room_create_notification(response_message)
      end
    end
  end

  private

  def render_message(message)
    rendered = MessagesController.render(partial: 'messages/message',
                              locals: { message: message, current_user: current_user})
    # Rails.logger.info "Rendered message: #{rendered.inspect}"
    rendered
  end

  def message_limit
    limit = 20 # a day
    recent_messages = current_user.sent_messages.last(limit) # .limit(limit) # asc / desc returning same order (asc) for all users in rails c and User.find(1) in localhost:3000 2025-07-15
    first_message_in_limit = recent_messages.first
    # Rails.logger.debug ">>> Recent message count: #{recent_messages.size}"
    # Rails.logger.debug ">>> Most recent message time: #{recent_messages.last&.created_at}"
    if recent_messages.size >= limit && first_message_in_limit.created_at > 24.hours.ago
      # Instead of flash or redirect, we can send an error back over the socket:
      transmit({ type: "error", message: "You’ve exceeded your limit of #{limit} messages in 24 hours" })
      return false
    end
    true
  end

end
