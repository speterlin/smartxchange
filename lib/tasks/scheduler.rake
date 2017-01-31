# need to require in order to include boards_helper
require "#{Rails.root}/app/helpers/boards_helper"
include BoardsHelper

task :send_weekly_notifications => :environment do
  @users = User.all
  @users.each do |user|
    if user.notifications.count > 0
      UserMailer.weekly_notifications(user, user.notifications.count).deliver
    end
  end
end

task :send_language_matches => :environment do
  # need to turn activerecord relation into array in order to use pop
  @users = User.all.to_a.shuffle
  20.times do
    UserMailer.language_matches(@users.pop, "match").deliver
  end
  20.times do
    UserMailer.language_matches(@users.pop, "exchange").deliver
  end
end

task :send_unread_board => :environment do
  @users = User.all.to_a.shuffle
  50.times do
    user = @users.pop
    board = Board.find(boards_match_id(user.language))
    if board_has_unread?(board, user)
      UserMailer.unread_board(user, board).deliver
    end
  end
end

task :send_unread_jobs => :environment do
  @users = User.all.to_a.shuffle
  board = Board.find(2)
  50.times do
    user = @users.pop
    if board_has_unread?(board, user)
      UserMailer.unread_jobs(user).deliver
    end
  end
end
