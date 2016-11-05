module PostsHelper

  def post_mark_read(notification)
    # only notifications pertaining to post here - like comment and vote notifications, may want to refactor and move this into notification helper to make this sql faster by something like user.notification.where
    notification.update(read: true)
  end

  def post_notification_check(vote_or_comment_or_follow_or_post_update, post, notified)
    # always create notification for comment, but only 1 new notification if it's a vote or a follow
    # maybe refactor, right now if a person updates comment more than once more than one notification will be created
    return true if vote_or_comment_or_follow_or_post_update.is_a?(Comment)
    return false if vote_or_comment_or_follow_or_post_update.is_a?(Vote) && post.notifications.where(read: false, notified_id: notified.id, sourceable_type: 'Vote').count > 0
    return false if vote_or_comment_or_follow_or_post_update.is_a?(Follow) && post.notifications.where(read: false, notified_id: notified.id, sourceable_type: 'Follow').count > 0
    return false if vote_or_comment_or_follow_or_post_update.is_a?(Post) && post.notifications.where(read: false, notified_id: notified.id, sourceable_type: 'Post').count > 0
    true
  end

  def post_create_notifications(vote_or_comment_or_follow_or_post_update, post)
    # first notification for post owner then for followers
    post_create_notification(vote_or_comment_or_follow_or_post_update, post) unless post.owner == vote_or_comment_or_follow_or_post_update.owner
    if post.followers.any?
      post.followers.each do |follower|
        next if vote_or_comment_or_follow_or_post_update.owner == follower
        post_create_notification(vote_or_comment_or_follow_or_post_update, post, follower)
      end
    end
  end

  def post_create_notification(vote_or_comment_or_follow_or_post_update, post, follower = nil)
    @notification = nil
    # maybe refactor, notified only placed here so don't have to declare as an instance variable
    notified = follower ? follower : post.owner
    if post_notification_check(vote_or_comment_or_follow_or_post_update, post, notified)
      @notification = Notification.create!(
        notified_id: notified.id,
        notifier_id: vote_or_comment_or_follow_or_post_update.owner.id,
        notifiable_type: 'Post',
        notifiable_id: post.id,
        sourceable_type: vote_or_comment_or_follow_or_post_update.class.name,
        sourceable_id: vote_or_comment_or_follow_or_post_update.id
      )
    end
    # maybe refactor, right now need to include UserHelper to call the below method
    if !@notification.nil?
      WebNotificationsChannel.broadcast_to(
        notified,
        posts_notifications: notified.posts_notifications.count,
        boards_notifications: user_boards_notifications_with_title(notified),
        total_notifications: notified.notifications.count,
        sound: true
      )
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
