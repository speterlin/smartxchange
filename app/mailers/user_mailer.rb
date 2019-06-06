class UserMailer < ApplicationMailer
  # Call this in rails console to email everyone without redirect_to, make sure to do <9 every 10min after initial batch due to smtp settings
  # @users = User.all
  # @users[0..48].each do |user|
  #     UserMailer.monthly_update(user, user.notifications.count).deliver_now
  # end

  # for using #a_or_an in emails
  add_template_helper(ApplicationHelper)
  # for using #user_convert_to_presented_language_level in related_material.html.erb&text.erb
  add_template_helper(UsersHelper)
  # needed for #num_to_month
  include ApplicationHelper
  # needed for #user_convert_to_language and #user_related_material
  include UsersHelper
  # only need for chat_room_interlocutor, maybe refactor and make this method a chat_room.rb method
  include ChatRoomsHelper

  # all emails where we're using normal footer_mail (rather than footer_mail_simple)
  before_action :set_footer_urls, only: [:welcome_new, :weekly_notifications, :monthly_update, :unread_board, :unread_jobs, :unread_materials, :related_material]
  # all emails where there is a login link
  before_action :set_login_url, only: [:welcome_new, :weekly_notifications, :monthly_update, :language_matches]
  # before_action :set_header_logo
  # bit of a hack, maybe refactor need @user to be set before sending, welcome new will always be true just there so doesn't enter method
  after_action :prevent_delivery_to_unsubscribed, except: [:welcome_new, :reset_password, :suspicious_activity, :premium_subscribe, :premium_unsubscribe, :account_activation]

  def account_activation(user)
    @user = user
    @activate_account_url = activate_account_user_settings_url(@user, @user.activation_token, email: @user.email)
    set_name_and_title_and_unsubscribe_and_header(@user, "Activate your smartXchange account")
  end

  def welcome_new(user)
    @user = user
    set_name_and_title_and_unsubscribe_and_header(@user, "Welcome to smartXchange")
  end

  def weekly_notifications(user, notifications)
    @user = user
    @notifications = notifications
    add_campaign_to_login(campaign("notifications"))
    add_campaign_to_footer(campaign("notifications"))
    set_name_and_title_and_unsubscribe_and_header(@user, "smartXchange Notifications")
  end

  def monthly_update(user, notifications)
    @user = user
    @notifications = notifications
    add_campaign_to_login(campaign("notifications"))
    add_campaign_to_footer(campaign("notifications"))
    set_name_and_title_and_unsubscribe_and_header(@user, "smartXchange enters its 12th and final month!")
  end

  def language_matches(user, exchange = false)
    # refactor this, a bit messy
    @user = user
    if exchange
      @matches = @user.sort_exchange[0..24].shuffle[0..5]
      campaign = campaign("exchanges")
      @notify_message = "Are you interested in exchanging your native #{user_convert_to_language(@user.nationality)} with the native #{@user.language} of any of the following users?"
      @login_message = "to find more native #{@user.language} speakers practicing #{user_convert_to_language(@user.nationality)}."
      title = "Have you messaged these language exchange options?"
    else
      @matches = @user.sort_method[0..24].shuffle[0..5]
      campaign = campaign("matches")
      @notify_message = "Are you interested in practicing #{@user.language} with any of the following users?"
      @login_message = "to find more people practicing #{@user.language}."
      title = "Have you messaged these language practice peers?"
    end
    @matches_token = @user.create_matches_token!
    if @matches.any?
      @match_urls = Hash.new
      @matches.each do |match|
        fetch_user_image(match)
        @match_urls[match.id] = [user_email_match_url(@user, @matches_token, match.id) + campaign, user_url(match) + campaign]
      end
    else
      mail.perform_deliveries = false
    end
    add_campaign_to_login(campaign)
    set_name_and_title_and_unsubscribe_and_header(@user, title)
  end

  def notify_match(interested_user, matched_user)
    @interested_user = interested_user
    # set as @user instead of @matched_user so don't have to change unsubscribe logic
    @user = matched_user
    # not using add_campaign since this is less lines of code, only need to add campaign to the view profile link
    @url_interested_user = user_url(@interested_user) + campaign("matches")
    fetch_user_image(@interested_user)
    set_name_and_title_and_unsubscribe_and_header(@user, "#{@interested_user.name} wants to practice #{@interested_user.language}")
  end

  def unread_board(user, board)
    @user = user
    # for this and unread_jobs a check for unread posts has already been called before email is called so grab the last (ordered desc) post posted on the board
    @board_url = board_url(board) + campaign("boards")
    add_campaign_to_footer(campaign("boards"))
    set_name_and_title_and_unsubscribe_and_header(@user, "Check out the latest posts on the #{@user.language} board!")
  end

  def unread_jobs(user)
    @user = user
    board = Board.find(2)
    @board_url = board_url(board) + campaign("jobs")
    add_campaign_to_footer(campaign("jobs"))
    set_name_and_title_and_unsubscribe_and_header(@user, "View the latest jobs on the Smart Jobs board!")
  end

  def unread_materials(user)
    @user = user
    @material = Material.last
    @material_url = user_url(@material.owner) + campaign("materials") + "#tutor-materials"
    add_campaign_to_footer(campaign("materials"))
    set_name_and_title_and_unsubscribe_and_header(@user, "#{@material.owner.name} has uploaded new material")
  end

  def related_material(user)
    @user = user
    @materials = user_related_material(@user)
    @material_urls = Hash.new
    @materials.each do |material|
      @material_urls[material.id] = user_url(material.owner) + campaign("materials") + "#tutor-materials"
    end
    add_campaign_to_footer(campaign("materials"))
    set_name_and_title_and_unsubscribe_and_header(@user, "We have found #{@materials.count} related materials for you!")
  end

  def new_conversation(chat_room)
    @user = chat_room.recipient
    @initiator = chat_room.initiator
    # not get @chat_room since for now chat_room is always initiated in initiator's language (to practice)
    @chat_room_url = conversation_url(chat_room) + campaign("conversations")
    fetch_user_image(@initiator)
    set_name_and_title_and_unsubscribe_and_header(@user, "#{@initiator.name} has started #{a_or_an(@initiator.language)} #{@initiator.language} conversation with you")
  end

  def new_message(message)
    @user = chat_room_interlocutor(message.chat_room, message.sender)
    @sender = message.sender
    @chat_room = message.chat_room
    @chat_room_url = conversation_url(message.chat_room) + campaign("conversations")
    fetch_user_image(@sender)
    set_name_and_title_and_unsubscribe_and_header(@user, "#{@sender.name} has sent you a message in your #{@chat_room.title} conversation")
  end

  def new_post(notification, mention = false)
    @user = notification.notified
    @notifier = notification.notifier
    @post = notification.notifiable
    @board = @post.board
    @board_url = board_url(@board) + campaign("boards")
    fetch_user_image(@notifier)
    @description = mention ? "has mentioned you in a post on the": "has updated a post you own or are following on the"
    title = mention ? "You have been mentioned in a post on the" : "You have a new post notification on the"
    set_name_and_title_and_unsubscribe_and_header(@user, "#{title} #{@board.title} board!")
  end

  def peer_review(user, other_user, chat_room)
    @user = user
    @other_user = other_user
    @chat_room = chat_room
    @peer_review_hash = Rails.application.message_verifier(:peer_review).generate(@other_user.id)
    # have to modify reviews campaign so it's tagged onto end of list of params chat_room_id and id
    @peer_review_url = new_user_review_url(@user, chat_room_id: @chat_room.id, id: @peer_review_hash) + "&" + campaign("reviews")[1..-1]
    fetch_user_image(@other_user)
    set_name_and_title_and_unsubscribe_and_header(@user, "Please review #{@other_user.name} in your #{@chat_room.title} conversation together")
  end

  def notify_review(user, other_user, review)
    @user = user
    @other_user = other_user
    @review = review
    @peer_review_url = user_url(@user) + campaign("reviews") + "#review-#{@review.id}"
    fetch_user_image(@other_user)
    set_name_and_title_and_unsubscribe_and_header(@user, "#{@other_user.name} has left you a review")
  end

  def reset_password(user, password)
    @user = user
    @password = password
    @url_change_password = change_password_user_settings_url(@user)
    set_name_and_title_and_unsubscribe_and_header(@user, "Password reset, smartXchange")
  end

  def suspicious_activity(user)
    @user = user
    set_name_and_title_and_unsubscribe_and_header(@user, "Suspicious Activity")
  end

  def premium_subscribe(user)
    @user = user
    set_name_and_title_and_unsubscribe_and_header(@user, "Welcome to smartXchange Premium")
  end

  def premium_unsubscribe(user)
    @user = user
    set_name_and_title_and_unsubscribe_and_header(@user, "Sorry to see you leave")
  end

  private

  def set_footer_urls
    @url_tutors = tutors_users_url
    @url_premium_subscription = about_url + "#premium"
  end

  def add_campaign_to_footer(campaign)
    # Maybe refactor, combine this and set_footer_urls, and move this and login_urls to views instead of setting urls here
    @url_tutors += campaign
    @url_premium_subscription = about_url + campaign + "#premium"
  end

  def set_login_url
    @url_login = login_url
  end

  def add_campaign_to_login(campaign)
    @url_login += campaign
  end

  def set_header_logo
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
  end

  # campaigns built with google url builder
  # assuming campaign comes in as plural
  def campaign(name)
    # don't singularize notifications, matches, or exchanges because these are emails that can send multiple notifications, matches, or exchanges
    "?utm_source=#{name}_email&utm_medium=email&utm_campaign=#{num_to_month(Time.now.month)}_#{name}"
  end

  def prevent_delivery_to_unsubscribed
    mail.perform_deliveries = false unless @user.email_subscription.send(action_name)
  end

  def fetch_user_image(user)
    # in production .url works as url should, but in development .url works as path and vice versa
    if Rails.env.production?
      # maybe refactor, if no image uploaded, need to fetch the image from default_url method, which for some reason wasn't finding the file - Errno::ENOENT: No such file or directory @ rb_sysopen - root_url + 'images/fallback/user/small_thumb_default.png'  even though the file exists and the link works (also wasn't able to use Rails.root since prepends 'app' to path), but this method works with remote fetch
      # need to use .url path without Rails.root due to images stored on amazon s3 servers
      # .path shows up nil for default_url call
      image_url = user.image.small_thumb.path ? user.image.small_thumb.url : root_url + user.image.small_thumb.url
      attachments.inline["#{user.name}.jpg"] = open(image_url).read
    else
      attachments.inline["#{user.name}.jpg"] = File.read("#{Rails.root}/public/#{user.image.small_thumb.url}")
    end
  end

  def set_name_and_title_and_unsubscribe_and_header(user, title)
    email_with_name = %("#{user.name}" <#{user.email}>)
    @unsubscribe_hash = Rails.application.message_verifier(:unsubscribe).generate(@user.id)
    @url_email_subscription = email_subscription_user_settings_url(@user, id: @unsubscribe_hash)
    # binding of collar easy way to get previous method name
    headers['X-SMTPAPI'] = '{"category": "' + binding.of_caller(0).eval('self').action_name + '"}'
    mail(to: email_with_name, subject: title)
  end

end
