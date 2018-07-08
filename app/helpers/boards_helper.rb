module BoardsHelper

  def board_unread?(board, user, read_of_board = nil)
    return false if board.id == 9 # update if change boards_postable
    return false if board.id == 2 && !user.premium_or_admin?
    read_of_board ||= user.reads.where(readable: board).first
    # maybe refactor, could also have this: return true unless user.read_boards.include?(board), but easier to use this variable here and below
    return true if read_of_board.nil?
    return true if board.updated_at > read_of_board.updated_at
    false
  end

  def boards_unread(user)
    unread_boards = Hash.new
    # at the moment reads only includes boards, in the future if it includes other objects, need to use an association in user.rb that takes reads.where(readable_type: "Board")
    user.reads.includes(:readable).each do |read|
      board = read.readable
      # maybe refactor and have hash store both true and false values for all boards, not doing it now since like having if unread_boards.any? in _header.html.erb, would have to use unless unread_boards.values.none? if have both true and false values
      unread_boards[board.id] = true if board_unread?(board, user, read)
    end
    unread_boards
  end

  def board_mark_read(board)
    # maybe refactor and add return if board.id == 9, right now can track who views the tags board by not including this
    # maybe refactor, this current setup (below) has less database calls, can change back to: current_user.read_boards << board unless current_user.read_boards.include?(board) and current_user.reads.where(readable: board).first.update(updated_at: Time.now)
    read_of_board = current_user.reads.where(readable: board).first
    if read_of_board
      read_of_board.update(updated_at: Time.now)
    else
      current_user.reads.create(readable: board)
    end
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

  # maybe refactor, name could be just board_render_post_or_comment_with_tags, issue with emails and hashtags avoided by adding (?<=\s|^) which only matches if tags are preceded by white space or content starts with it, assuming every name has already been checked, implement [^\s]+ for usertags matching to allow for letters with accents - allows for all punctuaction, if change regex need to change in application.js.erb (with workaround since js doesn't support look-behinds) and taggable.rb
  def board_render_post_or_comment_with_hashtags_and_usertags(content)
    content.gsub(/(?<=\s|^)#\w+/){|word| link_to word, "/boards/hashtag?tag=#{word.delete('#')}"}
    .gsub(/(?<=\s|^)@[^\s]+/){|name| link_to name, "/users/#{name.delete('@').split('.').join('%20').downcase}"}.html_safe
  end

  def boards_postable
    # all boards you can post to (all except the hashtag board)
    return Board.where.not(id: 9)
  end

end
