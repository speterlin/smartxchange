class UserMailer < ApplicationMailer
  # Call this in rails console to email everyone without redirect_to, make sure to do <9 every 10min after initial batch due to smtp settings
  # @users = User.all
  # @users[0..48].each do |user|
  #     UserMailer.monthly_update(user, user.notifications.count).deliver_now
  # end

  # for using a_or_an method in emails
  include ApplicationHelper
  include ChatRoomsHelper
  include UsersHelper
  add_template_helper(ApplicationHelper)

  # all emails where we're using normal footer_mail (rather than footer_mail_simple)
  before_action :set_footer_urls, only: [:welcome_new, :weekly_notifications, :monthly_update, :unread_board, :unread_jobs]
  # all emails where there is a login link
  before_action :set_login_url, only: [:welcome_new, :weekly_notifications, :monthly_update, :language_matches]
  before_action :set_header_logo
  # bit of a hack, maybe refactor need @user to be set before sending, welcome new will always be true just there so doesn't enter method
  after_action :prevent_delivery_to_unsubscribed, except: [:welcome_new, :reset_password, :suspicious_activity, :premium_subscribe, :premium_unsubscribe, :account_activation]

  def account_activation(user)
    @user = user
    # maybe refactor and get rid of cgi escape, according to hartl tutorial I need this
    @activate_account_url = "http://www.smartxchange.es/users/#{@user.id}/settings/activate_account/#{@user.activation_token}?email=#{CGI.escape(@user.email)}"
    set_name_and_title_and_unsubscribe(@user, "Activate your smartXchange account")
  end

  def welcome_new(user)
    @user = user
    set_name_and_title_and_unsubscribe(@user, "Welcome to smartXchange")
  end

  def weekly_notifications(user, notifications)
    # change this to users who want notifications eventually
    @user = user
    @notifications = notifications
    add_campaign_to_login(notifications_campaign)
    add_campaign_to_footer(notifications_campaign)
    set_name_and_title_and_unsubscribe(@user, "smartXchange Notifications")
  end

  def monthly_update(user, notifications)
    @user = user
    @notifications = notifications
    add_campaign_to_login(notifications_campaign)
    add_campaign_to_footer(notifications_campaign)
    set_name_and_title_and_unsubscribe(@user, "smartXchange is hosting its first event ever!")
  end

  def language_matches(user, match_or_exchange)
    @user = user
    if match_or_exchange == "match"
      @matches = @user.sort_method[0..24].shuffle[0..5]
      campaign = matches_campaign
      @notify_message = "Are you interested in practicing #{@user.language} with any of the following users?"
      @login_message = "to find more people practicing #{@user.language}."
      title = "Have you messaged these language practice peers?"
    elsif match_or_exchange == "exchange"
      @matches = @user.sort_exchange[0..24].shuffle[0..5]
      campaign = exchanges_campaign
      @notify_message = "Are you interested in exchanging your native #{user_convert_nationality_to_language(@user.nationality)} with the native #{@user.language} of any of the following users?"
      @login_message = "to find more native #{@user.language} speakers practicing #{user_convert_nationality_to_language(@user.nationality)}."
      title = "Have you messaged these language exchange options?"
    end
    @matches_token = @user.create_matches_token!
    @url_email_match = "http://www.smartxchange.es/users/#{@user.id}/email_match/#{@matches_token}/"
    campaign = match_or_exchange == "match" ? matches_campaign : exchanges_campaign
    if @matches.any?
      @match_urls = Hash.new
      @matches.each do |match|
        fetch_user_image(match)
        @match_urls[match.id] = [@url_email_match + match.id.to_s + campaign, "http://www.smartxchange.es/users/#{match.id}" + campaign]
      end
    end
    add_campaign_to_login(campaign)
    set_name_and_title_and_unsubscribe(@user, title)
  end

  def notify_match(interested_user, matched_user)
    @interested_user = interested_user
    # set as @user instead of @matched_user so don't have to change unsubscribe logic
    @user = matched_user
    # not using add_campaign since this is less lines of code, only need to add campaign to the view profile link
    @url_interested_user = "http://www.smartxchange.es/users/#{@interested_user.id}#{matches_campaign}"
    fetch_user_image(@interested_user)
    set_name_and_title_and_unsubscribe(@user, "#{@interested_user.name} wants to practice #{@interested_user.language}")
  end

  def unread_board(user, board)
    @user = user
    # for this and unread_jobs a check for unread posts has already been called before email is called so grab the last (ordered desc) post posted on the board
    @board_url = "http://www.smartxchange.es/boards/#{board.id}" + boards_campaign + (board.posts.any? ? "#post-#{board.posts.first.id}" : "")
    set_name_and_title_and_unsubscribe(@user, "Check out the latest posts on the #{@user.language} board!")
  end

  def unread_jobs(user)
    @user = user
    board = Board.find(2)
    @board_url = "http://www.smartxchange.es/boards/#{board.id}" + jobs_campaign + (board.posts.any? ? "#post-#{board.posts.first.id}" : "")
    set_name_and_title_and_unsubscribe(@user, "View the latest jobs on the Smart Jobs board!")
  end

  def new_conversation(chat_room)
    @user = chat_room.recipient
    @initiator = chat_room.initiator
    # not get @chat_room since for now chat_room is always initiated in initiator's language (to practice)
    @chat_room_url = "http://www.smartxchange.es/chat_rooms/#{chat_room.id}" + conversations_campaign
    fetch_user_image(@initiator)
    set_name_and_title_and_unsubscribe(@user, "#{@initiator.name} has started #{a_or_an(@initiator.language)} #{@initiator.language} conversation with you")
  end

  def new_message(message)
    @user = chat_room_interlocutor(message.chat_room, message.sender)
    @sender = message.sender
    @chat_room = message.chat_room
    @chat_room_url = "http://www.smartxchange.es/chat_rooms/#{message.chat_room.id}" + conversations_campaign
    fetch_user_image(@sender)
    set_name_and_title_and_unsubscribe(@user, "#{@sender.name} has sent you a message in your #{@chat_room.title} conversation")
  end

  def new_post(notification)
    @user = notification.notified
    @notifier = notification.notifier
    @post = notification.notifiable
    @board = @post.board
    @board_url = "http://www.smartxchange.es/boards/#{@board.id}" + posts_campaign
    fetch_user_image(@notifier)
    set_name_and_title_and_unsubscribe(@user, "You have a new post notification on the #{@board.title} board!")
  end

  def peer_review(user, other_user, chat_room)
    @user = user
    @other_user = other_user
    @chat_room = chat_room
    @peer_review_hash = Rails.application.message_verifier(:peer_review).generate(@other_user.id)
    @peer_review_url = "http://www.smartxchange.es/users/#{@user.id}/reviews/new#{reviews_campaign}&chat_room_id=#{@chat_room.id}&id=#{@peer_review_hash}"
    fetch_user_image(@other_user)
    set_name_and_title_and_unsubscribe(@user, "Please review #{@other_user.name} in your #{@chat_room.title} conversation together")
  end

  def notify_review(user, other_user, review)
    @user = user
    @other_user = other_user
    @review = review
    @peer_review_url = "http://www.smartxchange.es/users/#{@user.id}#{reviews_campaign}#review-#{@review.id}"
    fetch_user_image(@other_user)
    set_name_and_title_and_unsubscribe(@user, "#{@other_user.name} has left you a review")
  end

  def reset_password(user, password)
    @user = user
    @password = password
    @url_change_password = "http://www.smartxchange.es/users/#{@user.id}/settings/change_password"
    set_name_and_title_and_unsubscribe(@user, "Password reset, smartXchange")
  end

  def suspicious_activity(user)
    @user = user
    set_name_and_title_and_unsubscribe(@user, "Suspicious Activity")
  end

  def premium_subscribe(user)
    @user = user
    set_name_and_title_and_unsubscribe(@user, "Welcome to smartXchange Premium")
  end

  def premium_unsubscribe(user)
    @user = user
    set_name_and_title_and_unsubscribe(@user, "Sorry to see you leave")
  end

  private

  def set_footer_urls
    @url_xchange_option = "http://www.smartxchange.es/users/exchange"
  end

  def add_campaign_to_footer(campaign)
    @url_xchange_option += campaign
  end

  def set_login_url
    @url_login = "http://www.smartxchange.es/login"
  end

  def add_campaign_to_login(campaign)
    @url_login += "#{campaign}"
  end

  def set_header_logo
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
  end

  # campaigns built with google url builder
  def notifications_campaign
    "?utm_source=notifications_email&utm_medium=email&utm_campaign=january_notifications"
  end

  def matches_campaign
    "?utm_source=matches_email&utm_medium=email&utm_campaign=january_matches"
  end

  def exchanges_campaign
    "?utm_source=exchanges_email&utm_medium=email&utm_campaign=january_exchanges"
  end

  def conversations_campaign
    "?utm_source=conversation_email&utm_medium=email&utm_campaign=january_conversations"
  end

  def posts_campaign
    "?utm_source=post_email&utm_medium=email&utm_campaign=january_posts"
  end

  def boards_campaign
    "?utm_source=board_email&utm_medium=email&utm_campaign=january_boards"
  end

  def jobs_campaign
    "?utm_source=job_email&utm_medium=email&utm_campaign=january_jobs"
  end

  def reviews_campaign
    "?utm_source=review_email&utm_medium=email&utm_campaign=january_reviews"
  end

  def prevent_delivery_to_unsubscribed
    mail.perform_deliveries = false unless @user.email_subscription.send(action_name)
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

  def set_name_and_title_and_unsubscribe(user, title)
    email_with_name = %("#{user.name}" <#{user.email}>)
    @unsubscribe_hash = Rails.application.message_verifier(:unsubscribe).generate(@user.id)
    mail(to: email_with_name, subject: title)
  end

end
