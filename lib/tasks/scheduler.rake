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
    UserMailer.language_matches(@users.pop).deliver
  end
end
