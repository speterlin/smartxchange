class ApplicationController < ActionController::Base
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
    flash[:notice] = welcome_messages(current_user).sample
    ip_address = request.remote_ip
    current_user.update!(ip_address: ip_address) if ip_address
    redirect_to(session[:return_to] || board_path(Board.find_by_title(current_user.language)))
    session[:return_to] = nil
  end

  def welcome_messages(user)
    random_match = user.sort_exchange[0..24].sample
    random_match = user.sort_method[0..24].sample unless random_match
    messages = ["Visit the <a href=\"#{users_path}\">People</a> page and try the new Xchange option!", "Bored? Post something to a Board page and see how many votes it can get :)", "Start a free 7 day trial of our <a href=\"#{about_path}#premium\">Premium</a> membership today!"]
    messages += ["Have you tried messaging <a href=\"#{user_path(random_match)}\">#{random_match.name}, #{random_match.title}</a> for a language exchange or practice?"] if random_match
    # include 3 tutor profiles only works on production environment, maybe refactor
    if Rails.env.production?
      tutors_with_material = [User.find(1), User.find(131), User.find(329), User.find(340)]
      tutor = tutors_with_material.sample
      messages += ["Take a look at material uploaded by <a href=\"#{user_path(tutor)}#tutor-materials\">#{tutor.name}</a>!"]
    end
    messages
  end

  def require_signed_in!
    unless signed_in?
      flash[:error] = "Please log in."
      session[:return_to] = request.url
      redirect_to login_path
    end
  end

  def correct_user?
    # need this for settings maybe refactor
    id = params[:user_id] ? params[:user_id] : params[:id]
    @user = User.find_by_param(id)
    unless @user == current_user
      flash[:error] = "Unauthorized access"
      # this and correct _chat_room?, _post?, _comment? are not set to redirect_to :back because they can only be accessed by typing them in the url and therefore no http_referer is set
      redirect_to root_path
      return false
    end
    true
  end

  def set_time_zone
    min = cookies["time_zone"].to_i
    #  probably refactor later, the time zone offset is off UTC, but ActiveSupport::TimeZone[] adds it to London time, therefore have to adjust 1 hour in development
    min += 60 if Rails.env.development?
    Time.zone = ActiveSupport::TimeZone[-min.minutes]
  end

  def welcome_new(user)
    flash[:success] = "Welcome to smartXchange! Complete your profile and navigate to the People page to start practicing your language! Make sure to update your native country and birthdate to accurately match with language exchange options"
    UserMailer.welcome_new(user).deliver_later
    redirect_to user_path(user)
  end

  def premium_subscription
    flash[:error] = "Please send an email to speterlin12@gmail.com with the title 'Premium Membership - your name' and we will begin the process!"
    redirect_to root_path
  end

end
