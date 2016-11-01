module BoardsHelper

  def board_has_unread?(board)
    # hack job here and below method don't want to add another column to users maybe refactor, + 1 since delay in when board is updated and readable is updated upon new post / comment / vote / follow etc
    current_user.read_boards << board unless current_user.read_boards.include?(board)
    if board.updated_at > current_user.reads.where(readable: board).first.updated_at + 1
      return true
    end
    false
  end

  def boards_have_unread?
    Board.all.each do |board|
      return true if board_has_unread?(board)
    end
    false
  end

  def board_mark_read(board)
    current_user.reads.where(readable: board).first.update(updated_at: Time.now)
  end

end
