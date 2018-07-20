module PostsHelper

  def post_notification_check(sourceable, post, notified)
    # maybe refactor, right now doesn't matter if comment has a mention or not, only want one notification per user per comment create/update/mention
    return false if sourceable.is_a?(Comment) && post.notifications.where(read: false, notified_id: notified.id, sourceable: sourceable).count > 0
    return false if sourceable.is_a?(Vote) && post.notifications.where(read: false, notified_id: notified.id, sourceable_type: 'Vote').count > 0
    return false if sourceable.is_a?(Follow) && post.notifications.where(read: false, notified_id: notified.id, sourceable_type: 'Follow').count > 0
    # maybe refactor, if sourceable is a Post, it has to be the same as the given post, and notification is a post create/update/mention, right now doesn't matter if post has a mention or not, only want one notification per user per post create/update/mention
    return false if sourceable.is_a?(Post) && post.notifications.where(read: false, notified_id: notified.id, sourceable: sourceable).count > 0
    true
  end

  def post_create_notifications(sourceable, post)
    # first notification for post owner then for followers
    post_create_notification(sourceable, post, post.owner) unless post.owner == sourceable.owner
    if post.followers.any?
      post.followers.each do |follower|
        next if sourceable.owner == follower
        post_create_notification(sourceable, post, follower)
      end
    end
  end

  # maybe refactor and get rid of post parameter, but would have to implement some additional logic to deal with notifiable_id
  def post_create_notification(sourceable, post, notified, mention = false)
    if post_notification_check(sourceable, post, notified)
      notification = Notification.create!(
        notified_id: notified.id,
        notifier_id: sourceable.owner.id,
        notifiable: post,
        sourceable: sourceable
      )
      WebNotificationsChannel.broadcast_to(
        notified,
        boards_notifications_count: notified.boards_notifications_count,
        total_notifications_count: notified.notifications.count,
        sound: true
      )
      # delaying 30 seconds in case there are a lot of people getting updated
      UserMailer.delay(run_at: 30.seconds.from_now).new_post(notification, mention)
    end
  end

  def post_create_follow(post, user)
    return if post.followers.include?(user)
    return if post.owner == user
    follow = Follow.new(follower_id: user.id)
    post.follows << follow
    follow
  end

  def post_destroy_follow(post, user)
    return unless post.followers.include?(user)
    # shouldn't be a problem since owner can't be follower but a precautionary line of code
    return if post.owner == user
    # should be only 1 follows per person per post, may need to refactor
    follow = post.follows.where(follower_id: user.id).first
    follow.destroy
    follow
  end

end
