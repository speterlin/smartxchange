module UsersHelper

  #false in quotations works on heroku but not local server
  def user_count_unread(user)
    user.notifications.where(read: false).count
  end

  def user_count_unread_chat_rooms(user)
    user.chat_rooms_notifications.count
  end

  def user_count_unread_posts(user)
    user.posts_notifications.count
  end

  # probably need to refactor this and method below
  def user_count_unread_board_notifications(user, board)
    count = 0
    user.posts_notifications.each do |post_notification|
      count += 1 if post_notification.notifiable.board_id == board.id
    end
    count
  end

  def user_boards_notifications(user)
    boards_notifications = Hash.new
    Board.all.each do |board|
      # maybe refactor get rid of board title
      boards_notifications[board.id] = [board.title, user_count_unread_board_notifications(user, board)]
    end
    boards_notifications
  end

  def user_first_unread_post(user)
    user.posts_notifications.first
  end

  def user_convert_language_level(rating)
    if rating == 1
      return "A1 - beginner"
    elsif rating == 2
      return "A2 - elementary"
    elsif rating == 3
      return "B1 - intermediate"
    elsif rating == 4
      return "B2 - upper intermediate"
    elsif rating == 5
      return "C1 - advanced"
    elsif rating == 6
      return "C2 - master"
    end
  end

  def user_convert_language_level_to_rating(level)
    # assuming level always comes in as lower case
    if level == "a1"
      return 1
    elsif level == "a2"
      return 2
    elsif level == "b1"
      return 3
    elsif level == "b2"
      return 4
    elsif level == "c1"
      return 5
    elsif level == "c2"
      return 6
    end
  end

  def user_convert_nationality_to_img(nationality)
    image_tag("country-flags/#{nationality}-flag-circular.png", alt: "#{nationality}")
  end

end
