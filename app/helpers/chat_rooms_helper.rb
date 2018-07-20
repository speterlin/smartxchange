module ChatRoomsHelper

  # maybe refactor to something like user.id == chat_room.recipient_id ? chat_room.initiator_id so don't have to include :recipient and :initiator in chat_rooms_controller.rb#index, but would still need to fetch the resulting user information resulting in a database ping
  def chat_room_interlocutor(chat_room, user)
    user == chat_room.recipient ? chat_room.initiator : chat_room.recipient
  end

  # using select instead of where because that chat_room is loaded with notifications and we don't have to query the database again
  def chat_room_count_unread(chat_room, user)
    chat_room.notifications.select {|notification| notification.read == false && notification.notified_id == user.id}.count
  end

  # maybe refactor once have mentions in messages, method ensures user has at most 1 unread notification for given chat_room, ensures only 1 notification is created per new message(s) created
  def chat_room_notification_check(chat_room, receiver)
    return false if chat_room.notifications.where(read: false, notified_id: receiver.id).count > 0
    true
  end

  def chat_room_mark_read(chat_room, notified)
    # maybe refactor to delete notification (here and other notification updates), this method assumes only one notification is created per new message(s) in chat room(by chat_room_notification_check method)
    chat_room.notifications.where(read: false, notified_id: notified.id).update(read: true)
  end

  def chat_room_create_notification(message)
    # maybe refactor recipient call, preload association for use in #chat_room_interlocutor
    recipient = chat_room_interlocutor(message.chat_room, message.sender)
    if chat_room_notification_check(message.chat_room, recipient)
      Notification.create(
        notified_id: recipient.id,
        notifier_id: message.sender.id,
        notifiable: message.chat_room,
        sourceable: message
      )
      WebNotificationsChannel.broadcast_to(
        recipient,
        # maybe refactor, 2 calls to database here and broadcast below, one for chat_room specific notifications, other for general notifications
        chat_rooms_notifications: recipient.chat_rooms_notifications.count,
        total_notifications_count: recipient.notifications.count,
        sound: true
      )
      # if sending from this chat room mark last notification from sender as read
      chat_room_mark_read(message.chat_room, message.sender)
      # using message.sender in code below because of potential conflict if chatbot is responding
      WebNotificationsChannel.broadcast_to(
        message.sender,
        chat_rooms_notifications: message.sender.chat_rooms_notifications.count,
        total_notifications_count: message.sender.notifications.count,
        sound: false
      )
    end
  end

end
