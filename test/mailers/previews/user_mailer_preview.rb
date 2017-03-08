# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def account_activation
    UserMailer.account_activation(User.first)
  end

  def welcome_new
    UserMailer.welcome_new(User.first)
  end

  def weekly_notifications
    UserMailer.weekly_notifications(User.first, 1)
  end

  def monthly_update
    UserMailer.monthly_update(User.first, 2)
  end

  def language_matches
    UserMailer.language_matches(User.first, "match")
  end

  def notify_match
    UserMailer.notify_match(User.first, User.second)
  end

  def unread_board
    board = Board.find_by_title(User.first.language)
    UserMailer.unread_board(User.first, board)
  end

  def unread_jobs
    UserMailer.unread_jobs(User.first)
  end

  def new_conversation
    UserMailer.new_conversation(ChatRoom.first)
  end

  def new_message
    UserMailer.new_message(Message.last)
  end

  def new_post
    notification = Notification.where(read: false, notifiable_type: 'Post').last
    UserMailer.new_post(notification)
  end

  def peer_review
    UserMailer.peer_review(ChatRoom.first.initiator, ChatRoom.first.recipient, ChatRoom.first)
  end

  def notify_review
    UserMailer.notify_review(Review.last.reviewable, Review.last.reviewer, Review.last)
  end

  def reset_password
    UserMailer.reset_password(User.first, SecureRandom.urlsafe_base64(6))
  end

  def suspicious_activity
    UserMailer.suspicious_activity(User.first)
  end

  def premium_subscribe
    UserMailer.premium_subscribe(User.first)
  end

  def premium_unsubscribe
    UserMailer.premium_unsubscribe(User.first)
  end

end
