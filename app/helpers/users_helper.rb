module UsersHelper

  # probably need to refactor the below 3 methods, this method has a bug - counting twice if there's a match
  def user_count_unread_board_notifications(user, board)
    count = 0
    user.posts_notifications.each do |post_notification|
      # refactor, hack job for now have to add where read == false since association is lagging
      count += 1 if post_notification.notifiable.board_id == board.id && post_notification.read == false
    end
    count
  end

  def user_first_unread_board_notification(user, board)
    user.posts_notifications.each do |post_notification|
      return post_notification if post_notification.notifiable.board_id == board.id
    end
  end

  def user_boards_notifications_with_title(user)
    boards_notifications = Hash.new
    Board.all.each do |board|
      # maybe refactor get rid of board title, need for web notifications channel displaying in header
      boards_notifications[board.id] = [board.title, user_count_unread_board_notifications(user, board)]
    end
    boards_notifications
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
