module ChatRoomsHelper

  def chat_room_interlocutor(chat_room, user)
    user == chat_room.recipient ? chat_room.initiator : chat_room.recipient
  end

  # using select instead of where because that chat_room is loaded with notifications and we don't have to query the database again
  def chat_room_count_unread(chat_room, user)
    chat_room.notifications.select {|notification| notification.read == false && notification.notified_id == user.id}.count
  end

  # Ensures only 1 notification is created per new message(s) created
  def chat_room_notification_check(chat_room, receiver)
    if chat_room.notifications.where(read: false, notified_id: receiver.id).count > 0
      return false
    end
    true
  end

  def chat_room_mark_read(chat_room, notified)
    # assuming only one notification is created per new message(s) in chat room, by above method, maybe refactor to delete notification
    chat_room.notifications.where(read: false, notified_id: notified.id).update(read: true)
  end

  def chat_room_create_notification(message)
    # maybe refactor and implement a better method than this instance variable in the future
    @notification = nil
    recipient = chat_room_interlocutor(message.chat_room, message.sender)
    if chat_room_notification_check(message.chat_room, recipient)
      @notification = Notification.create!(
        notified_id: recipient.id,
        notifier_id: message.sender.id,
        notifiable_type: 'ChatRoom',
        notifiable_id: message.chat_room.id,
        sourceable_type: 'Message',
        sourceable_id: message.id
      )
    end
    # using message.sender in code below because of potential conflict if chatbot is responding
    if !@notification.nil?
      WebNotificationsChannel.broadcast_to(
        recipient,
        chat_rooms_notifications: recipient.chat_rooms_notifications.count,
        total_notifications: recipient.notifications.count,
        sound: true
      )
      # if sending from this chat room mark last notification from sender as read
      chat_room_mark_read(message.chat_room, message.sender)
      WebNotificationsChannel.broadcast_to(
        message.sender,
        chat_rooms_notifications: message.sender.chat_rooms_notifications.count,
        total_notifications: message.sender.notifications.count,
        sound: false
      )
    end
  end

end
