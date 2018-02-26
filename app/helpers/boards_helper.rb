module BoardsHelper

  def board_has_unread?(board, user)
    return false if board.id == 2 && !user.premium_or_admin?
    # hack job here and below method don't want to add another column to users maybe refactor, + 1 since delay in when board is updated and readable is updated upon new post / comment / vote / follow etc
    user.read_boards << board unless user.read_boards.include?(board)
    if board.updated_at > user.reads.where(readable: board).first.updated_at + 1
      return true
    end
    false
  end

  def boards_have_unread?(user)
    Board.all.each do |board|
      return true if board_has_unread?(board, user)
    end
    false
  end

  def board_mark_read(board)
    current_user.reads.where(readable: board).first.update(updated_at: Time.now)
  end

  def board_capitalize(string)
    # refactor not beautiful code
    result = ""
    string.split(" ").each_with_index do |sub_string, idx|
      result += sub_string.capitalize
      result += " " if idx != string.split(" ").count - 1
    end
    result
  end

  # assuming every name has already been checked, downcasing so not case sensitive
  def board_render_post_or_comment_with_hashtags_and_usertags(content)
    content.gsub(/#\w+/){|word| link_to word, "/boards/hashtag?tag=#{word.delete('#')}"}
    .gsub(/@[\w+\.?]+/){|name| link_to name, "/users/#{name.delete('@').split('.').join('%20').downcase}"}.html_safe
  end

end
