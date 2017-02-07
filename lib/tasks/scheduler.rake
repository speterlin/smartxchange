# need to require in order to include users and boards _helper
require "#{Rails.root}/app/helpers/boards_helper"
require "#{Rails.root}/app/helpers/users_helper"
include UsersHelper
include BoardsHelper

task :send_language_matches => :environment do
  # Cycle repeats every Sunday morning
  user_weekly_beginning_and_end(0).each do |user|
    UserMailer.language_matches(user, ["match", "exchange"].sample).deliver
  end
end

task :send_unread_board => :environment do
  # Cycle repeats every Monday morning
  user_weekly_beginning_and_end(1).each do |user|
    board = Board.find(boards_match_id(user.language))
    if board_has_unread?(board, user)
      UserMailer.unread_board(user, board).deliver
    end
  end
end

task :send_unread_jobs => :environment do
  board = Board.find(2)
  # Cycle repeats every Tuesday morning
  user_weekly_beginning_and_end(2).each do |user|
    if board_has_unread?(board, user)
      UserMailer.unread_jobs(user).deliver
    end
  end
end

task :send_weekly_notifications => :environment do
  # Once every Wednesday morning
  if user_days_from_beginning_of_year % 7 == 3
    @users = User.all
    @users.each do |user|
      if user.notifications.count > 0
        UserMailer.weekly_notifications(user, user.notifications.count).deliver
      end
    end
  end
end
