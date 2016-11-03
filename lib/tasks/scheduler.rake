task :send_weekly_notifications => :environment do
  def user_count_unread(user)
    user.notifications.where(read: false).count
  end
  @users = User.all
  @users.each do |user|
    if user_count_unread(user) > 0
      UserMailer.weekly_notifications(user, user_count_unread(user)).deliver
    end
  end
end

task :send_language_matches => :environment do
  # need to turn activerecord relation into array in order to use pop
  @users = User.all.to_a.shuffle
  20.times do
    UserMailer.language_matches(@users.pop).deliver
  end
end
