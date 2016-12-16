class UserMailer < ApplicationMailer
  # Call this in rails console to email everyone without redirect_to, make sure to do <9 every 10min after initial batch due to smtp settings
  # @users = User.all
  # @users[0..48].each do |user|
  #     UserMailer.monthly_update(user, user.notifications.count).deliver_now
  # end

  # for using a_or_an method in emails
  include ApplicationHelper
  include ChatRoomsHelper
  include BoardsHelper
  add_template_helper(ApplicationHelper)

  # all places where we're using footer_mail with all links
  before_action :set_footer_urls, only: [:welcome_new, :unread_board, :weekly_notifications, :monthly_update]
  before_action :set_header_logo
  # bit of a hack, maybe refactor need @user to be set before sending, welcome new will always be true just there so doesn't enter method
  after_action :prevent_delivery_to_unsubscribed, except: [:welcome_new, :reset_password, :suspicious_activity, :premium_subscribe, :premium_unsubscribe]

  def welcome_new(user)
    @user = user
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: 'Welcome to smartXchange')
  end

  def weekly_notifications(user, notifications)
    # change this to users who want notifications eventually
    @user = user
    @notifications = notifications
    # built with google url builder
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    add_campaign_to_footer(notifications_campaign)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: 'smartXchange Notifications')
  end

  def monthly_update(user, notifications)
    @user = user
    @notifications = notifications
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    add_campaign_to_footer(notifications_campaign)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: 'smartXchange enters its 5th month!')
  end

  def reset_password(user, password)
    @user = user
    @password = password
    @url_change_password = "http://www.smartxchange.es/users/#{@user.id}/settings/change_password"
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: 'Password reset, smartXchange')
  end

  def language_matches(user)
    @user = user
    @matches = @user.sort_method[0..5]
    @matches_token = @user.create_matches_token!
    @url_email_match = "http://www.smartxchange.es/users/#{@user.id}/email_match/#{@matches_token}/"
    if @matches.any?
      @match_urls = Hash.new
      @matches.each do |match|
        fetch_user_image(match)
        @match_urls[match.id] = [@url_email_match + match.id.to_s + matches_campaign, "http://www.smartxchange.es/users/#{match.id}" + matches_campaign]
      end
    end
    @url = "http://www.smartxchange.es/login" + matches_campaign
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: 'Have you messaged these language practice peers?')
  end

  def notify_match(interested_user, matched_user)
    @interested_user = interested_user
    # set as @user instead of @matched_user so don't have to change unsubscribe logic
    @user = matched_user
    # not using add_campaign since this is less lines of code, only need to add campaign to the view profile link
    @url_interested_user = "http://www.smartxchange.es/users/#{@interested_user.id}#{matches_campaign}"
    fetch_user_image(@interested_user)
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: "#{@interested_user.name} wants to practice #{@interested_user.language}")
  end

  def suspicious_activity(user)
    @user = user
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: 'Suspicious Activity')
  end

  def premium_subscribe(user)
    @user = user
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: 'Welcome to smartXchange Premium')
  end

  def premium_unsubscribe(user)
    @user = user
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: 'Sorry to see you leave')
  end

  def new_conversation(chat_room)
    @user = chat_room.recipient
    @initiator = chat_room.initiator
    # not get @chat_room since for now chat_room is always initiated in initiator's language (to practice)
    @chat_room_url = "http://www.smartxchange.es/chat_rooms/#{chat_room.id}" + conversations_campaign
    fetch_user_image(@initiator)
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: "#{@initiator.name} has started #{a_or_an(@initiator.language)} #{@initiator.language} conversation with you")
  end

  def new_message(message)
    @user = chat_room_interlocutor(message.chat_room, message.sender)
    @sender = message.sender
    @chat_room = message.chat_room
    @chat_room_url = "http://www.smartxchange.es/chat_rooms/#{message.chat_room.id}" + conversations_campaign
    fetch_user_image(@sender)
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: "#{@sender.name} has sent you a message in your #{@chat_room.title} conversation")
  end

  def peer_review(user, other_user, chat_room)
    @user = user
    @other_user = other_user
    @chat_room = chat_room
    @peer_review_hash = Rails.application.message_verifier(:peer_review).generate(@other_user.id)
    @peer_review_url = "http://www.smartxchange.es/users/#{@user.id}/reviews/new#{reviews_campaign}&chat_room_id=#{@chat_room.id}&id=#{@peer_review_hash}"
    fetch_user_image(@other_user)
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: "Please review #{@other_user.name} in your #{@chat_room.title} conversation together")
  end

  def notify_review(user, other_user, review)
    @user = user
    @other_user = other_user
    @review = review
    @peer_review_url = "http://www.smartxchange.es/users/#{@user.id}#{reviews_campaign}#review-#{@review.id}"
    fetch_user_image(@other_user)
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: "#{@other_user.name} has left you a review")
  end

  def unread_board(user, board)
    @user = user
    @board_url = "http://www.smartxchange.es/boards/#{board.id}" + boards_campaign + "#post-#{board.posts.first.id}"
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    set_unsubscribe_hash
    mail(to: email_with_name, subject: "Check out the latest posts on the #{@user.language} board!")
  end

  private

  def set_footer_urls
    @url  = "http://www.smartxchange.es/login"
    @url_mobile_tutorial = "http://www.smartxchange.es/about#video-mobile"
    @url_premium = "http://www.smartxchange.es/about#premium"
  end

  def set_header_logo
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
  end

  def add_campaign_to_footer(string)
    @url += "#{string}"
    @url_mobile_tutorial = "http://www.smartxchange.es/about#{string}#video-mobile"
    @url_premium = "http://www.smartxchange.es/about#{string}#premium"
  end

  def notifications_campaign
    "?utm_source=notifications_email&utm_medium=email&utm_campaign=december_notifications"
  end

  def matches_campaign
    "?utm_source=matches_email&utm_medium=email&utm_campaign=december_matches"
  end

  def conversations_campaign
    "?utm_source=conversation_email&utm_medium=email&utm_campaign=december_conversations"
  end

  def boards_campaign
    "?utm_source=board_email&utm_medium=email&utm_campaign=december_boards"
  end

  def reviews_campaign
    "?utm_source=review_email&utm_medium=email&utm_campaign=december_reviews"
  end

  def prevent_delivery_to_unsubscribed
    mail.perform_deliveries = false unless @user.email_subscription.send(action_name)
  end

  def set_unsubscribe_hash
    @unsubscribe_hash = Rails.application.message_verifier(:unsubscribe).generate(@user.id)
  end

  def fetch_user_image(user)
    # in production .url works as url should, but in development .url works as path and vice versa
    if Rails.env.production?
      # maybe refactor, if no image uploaded, need to fetch the image from default_url method, which for some reason wasn't finding the file - Errno::ENOENT: No such file or directory @ rb_sysopen - http://www.smartxchange.es/images/fallback/user/small_thumb_default.png  even though the file exists and the link works (also wasn't able to use Rails.root since prepends 'app' to path), but this method works with remote fetch
      # need to use .url path without Rails.root due to images stored on amazon s3 servers
      # .path shows up nil for default_url call
      image_url = user.image.small_thumb.path ? user.image.small_thumb.url : "http://www.smartxchange.es#{user.image.small_thumb.url}"
      attachments.inline["#{user.name}.jpg"] = open(image_url).read
    else
      attachments.inline["#{user.name}.jpg"] = File.read("#{Rails.root}/public/#{user.image.small_thumb.url}")
    end
  end

end
