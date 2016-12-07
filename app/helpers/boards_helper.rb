module BoardsHelper

  def board_has_unread?(board, user)
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

  def boards_match_id(language)
    if language == "Spanish"
      return 1
    elsif language == "English"
      return 3
    elsif language == "Italian"
      return 4
    elsif language == "German"
      return 5
    elsif language == "French"
      return 6
    end
  end

end
