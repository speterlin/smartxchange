class SessionsController < ApplicationController

  skip_before_action :require_signed_in!, only: [:new, :create, :omniauth_callback, :register_with_linkedin, :login_with_linkedin]

  def new
    redirect_to users_path if signed_in?
  end

  def create
    # maybe refactor find_by_credentials, need all these is_a?(User) because method can return just an email as well
    @user = User.find_by_credentials(params[:user])
    if @user.is_a?(User)
      # maybe refactor, this is repeated below, can't get around calling redirect twice
      unless @user.activated?
        flash[:error] = "User not activated, please check your email and activate account"
        redirect_to login_path and return
      end
      sign_in!(@user)
      normal_sign_in
    else
      @email = @user
      flash.now[:error] = "Invalid email and/or password"
      render :new
    end
  end

  def destroy
    sign_out!
    redirect_to login_path
  end

  # maybe refactor and move omniauth methods to users_controller
  def register_with_linkedin
    if @user
      flash[:error] = "Linkedin account already registered with smartXchange, please login with your Linkedin"
      redirect_to login_path and return
    else
      @user = User.create_with_omniauth(auth_hash)
      flash[:success] = "Please check your email (registered with Linkedin) for account activation. If you do not see the email please check your spam and promotion mailboxes."
      UserMailer.account_activation(@user).deliver_later
      redirect_to signup_path and return
    end
  end

  def login_with_linkedin
    if @user
      unless @user.activated?
        flash[:error] = "User not activated, please check your email (registered with Linkedin) and activate account"
        redirect_to login_path and return
      end
      sign_in!(@user)
      normal_sign_in
    else
      flash[:error] = "No Linkedin account registered with smartXchange, please register"
      redirect_to signup_path and return
    end
  end

  def add_or_update_linkedin
    if @user && @user == current_user #update
      current_user.update_with_omniauth(auth_hash)
      flash[:success] = "Linkedin information updated"
    elsif @user && @user != current_user #adding Linkedin but someone else is associated with this Linkedin
      flash[:error] = "Linkedin account already registered with another account"
    else #add
      current_user.add_with_omniauth(auth_hash)
      flash[:success] = "Linkedin added to profile"
    end
    redirect_to user_path(current_user) and return
  end

  def omniauth_callback
    @user = User.where(:provider => auth_hash['provider'], :uid => auth_hash['uid'].to_s).first
    if User.where(:email => auth_hash['info']['email'].downcase).first && !@user && (request.referer == login_url || request.referer == signup_url)
      flash[:error] = "User with this email already exists, please log in and add Linkedin to your profile"
      redirect_to login_path and return
    end
    if request.referer == signup_url
      register_with_linkedin
    elsif request.referer == login_url
      login_with_linkedin
    elsif request.referer == user_url(current_user)
      add_or_update_linkedin
    end
  end

  protected

  def auth_hash
    # maybe add something here about returning if no auth_hash
    request.env['omniauth.auth']
  end

end
