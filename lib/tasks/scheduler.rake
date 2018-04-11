# need to require in order to include users and boards _helper
require "#{Rails.root}/app/helpers/boards_helper"
require "#{Rails.root}/app/helpers/users_helper"
include UsersHelper
include BoardsHelper

task :send_language_matches => :environment do
  # Cycle repeats every Sunday (2017) morning
  users_group_by_day_of_week_and_group_num(0).each do |user|
    UserMailer.language_matches(user, ["match", "exchange"].sample).deliver
  end
end

task :send_unread_board => :environment do
  # Cycle repeats every Monday (2017) morning
  users_group_by_day_of_week_and_group_num(1).each do |user|
    board = Board.find_by_title(user.language)
    if board_has_unread?(board, user)
      UserMailer.unread_board(user, board).deliver
    end
  end
end

task :send_unread_jobs => :environment do
  board = Board.find(2)
  # Cycle repeats every Tuesday (2017) morning
  users_group_by_day_of_week_and_group_num(2).each do |user|
    if board_has_unread?(board, user)
      UserMailer.unread_jobs(user).deliver
    end
  end
end

task :send_weekly_notifications => :environment do
  # Once every Wednesday (2017) morning, if number of users gets big enough have to make sure this task can still execute
  if user_days_from_beginning_of_year % 7 == 3
    @users = User.all
    @users.each do |user|
      if user.notifications.count > 0
        UserMailer.weekly_notifications(user, user.notifications.count).deliver
      end
    end
  end
end

task :send_unread_materials => :environment do
  # Cycle repeats every Thursday (2017) morning
  users_group_by_day_of_week_and_group_num(4).each do |user|
    if user_has_unread_materials?(user)
      UserMailer.unread_materials(user).deliver
    end
  end
end

task :update_posts_image_with_opengraph => :environment do
  # Maybe refactor, do this once a week every Friday (2017) morning, since it causes board to have unread posts
  if user_days_from_beginning_of_year % 7 == 5
    Post.where.not(url: nil).each do |post|
      post.upload_or_update_image
      post.save
    end
  end
end

task :send_related_material => :environment do
  # maybe refactor, might be able to do this on top of task :update_posts... Cycle repeats every Saturday (2017) morning
  users_group_by_day_of_week_and_group_num(6).each do |user|
    if user_related_material(user).any?
      UserMailer.related_material(user).deliver
    end
  end
end
