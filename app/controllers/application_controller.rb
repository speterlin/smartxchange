class ApplicationController < ActionController::Base
  include BoardsHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?

  before_action :require_signed_in!, :set_time_zone

  private

  def current_user
    return nil unless session[:token]
    @current_user ||= User.find_by_session_token(session[:token])
  end

  def signed_in?
    !!current_user
  end

  def sign_out!
    current_user.try(:reset_token!)
    session[:token] = nil
  end

  def sign_in!(user)
    @current_user = user
    session[:token] = user.reset_token!
  end

  def normal_sign_in
    random_match = current_user.sort_method[0..24].sample
    flash[:notice] = "Welcome back #{current_user.name}! Have you tried messaging <a href=\"#{user_path(random_match)}\">#{random_match.name}, #{random_match.title}</a>?"
    redirect_to(session[:return_to] || get_user_board_path(current_user))
    session[:return_to] = nil
  end

  def require_signed_in!
    unless signed_in?
      flash[:error] = "Please log in."
      session[:return_to] = request.url
      redirect_to login_path
    end
    # raise 'Auth Error' unless signed_in? #for $http requests
  end

  def correct_user?
    # need this for settings maybe refactor
    id = params[:user_id] ? params[:user_id] : params[:id]
    @user = User.find(id)
    unless @user == current_user
      flash[:error] = "Unauthorized access"
      # this and correct_chat_room? are not set to redirect_to :back because they can only be accessed by typing them in the url and therefore no http_referer is set
      redirect_to users_path
      return false
    end
    true
  end

  def correct_chat_room?
    @chat_room = ChatRoom.find(params[:id])

    # maybe move the end of this method into chat_room.rb
    unless (@chat_room.initiator == current_user || @chat_room.recipient == current_user)
      flash[:error] = "Unauthorized access"
      redirect_to users_path
    end
  end

  def set_time_zone
    min = cookies["time_zone"].to_i
    #  probably refactor later, the time zone offset is off UTC, but ActiveSupport::TimeZone[] adds it to London time, therefore have to adjust 1 hour in development, 2 hours in production (don't know reason for difference in production)
    min += 60 if Rails.env.development?
    min += 120 if Rails.env.production?
    Time.zone = ActiveSupport::TimeZone[-min.minutes]
  end

  def welcome_new(user)
    flash[:success] = "Welcome to smartXchange! Complete your profile and start networking and practicing your language! Make sure to update your nationality so that your country's flag will be displayed to others when they talk with you"
    UserMailer.welcome_new(user).deliver_later
    redirect_to user_path(user)
  end

  def get_user_board_path(user)
    board = Board.find(boards_match_id(user.language))
    if board_has_unread?(board, user)
      # precautionary step in case board is updated and there are no posts (like if I update the description of an empty board), maybe refactor later
      path = board_path(board) + (board.posts.any? ? "#post-#{board.posts.first.id}" : "")
    else
      path = board_path(board)
    end
    path
  end

  def indiegogo_campaign
    flash[:error] = "Please contribute to our <a href=\"https://www.indiegogo.com/at/smartxchange\">Indiegogo Campaign</a> and claim your perk to gain access to the platform."
    redirect_to new_user_path
  end

end
