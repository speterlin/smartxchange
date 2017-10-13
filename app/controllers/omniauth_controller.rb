class OmniauthController < ApplicationController

  skip_before_action :require_signed_in, only: [:register, :login, :create, :login_with_omniauth, :callback]

  def register
    session[:omniauth] = "register"
    redirect_to "/auth/linkedin"
  end

  def add_or_update
    session[:omniauth] = "add_or_update"
    redirect_to "/auth/linkedin"
  end

  def login
    session[:omniauth] = "login"
    redirect_to "/auth/linkedin"
  end

  def create
    if @user
      flash[:error] = "Linkedin account already registered with smartXchange, please login with your Linkedin"
      redirect_to login_path and return
    else
      # refactor: here, update_with_omniauth!, and add_with_omniauth! call we can do an if @user and output errors if there was a problem creating user, but have to be wary of save_valid_attributes call
      @user = User.create_with_omniauth(auth_hash)
      flash[:success] = "Please check your email (registered with Linkedin) for account activation. If you do not see the email please check your spam and promotion mailboxes."
      UserMailer.account_activation(@user).deliver_later
      redirect_to signup_path and return
    end
  end

  # refactor and add extra validation (i.e. correct_user), and maybe add if else statement for handling delete_omniauth! errors
  def destroy
    current_user.delete_omniauth!
    redirect_to user_path(current_user)
  end

  # refactor, repeat code here and in sessions_controller.rb#create
  def login_with_omniauth
    if @user
      unless @user.activated?
        flash[:error] = "User not activated, please check your email (registered with Linkedin) and activate account"
        redirect_to login_path and return
      end
      sign_in!(@user)
      normal_sign_in!
    else
      flash[:error] = "No Linkedin account registered with smartXchange, please register"
      redirect_to signup_path and return
    end
  end

  def add_or_update_omniauth!
    if @user && @user == current_user # update
      # refactor, hack job hare and in add_with_omniauth! call that allows us to save valid attributes to database and display any errors with uploading
      notices = current_user.update_with_omniauth!(auth_hash)
      notices.empty? ? flash[:success] = "Linkedin information updated" : flash[:notice] = "Linkedin information updated, but #{notices}"
    elsif @user && @user != current_user # adding Linkedin but someone else is associated with this Linkedin
      flash[:error] = "Linkedin account already registered with another account"
    else # add
      notices = current_user.add_with_omniauth!(auth_hash)
      notices.empty? ? flash[:success] = "Linkedin added to profile" : flash[:notice] = "Linkedin information added, but #{notices}"
    end
    redirect_to user_path(current_user) and return
  end

  # later refactor and add check for which type of omniauth (Linkedin, Github, etc. and tailor this method appropriately)
  def callback
    # maybe refactor, don't know if I need the to_s
    @user = User.where(:provider => auth_hash['provider'], :uid => auth_hash['uid'].to_s).first
    # maybe refactor and make this a validation, like a uniqueness on email, uid, and provider
    if User.where(:email => auth_hash['info']['email'].downcase).first && !@user && (request.referer == login_url || request.referer == signup_url)
      flash[:error] = "User with this email already exists, please log in and add Linkedin to your profile"
      redirect_to login_path and return
    end
    if session[:omniauth] == "register"
      session[:omniauth] = nil
      create
    elsif session[:omniauth] == "login"
      session[:omniauth] = nil
      login_with_omniauth
    elsif session[:omniauth] == "add_or_update"
      session[:omniauth] = nil
      add_or_update_omniauth!
    end
  end

  protected

  def auth_hash
    # maybe add something here about returning if no auth_hash
    request.env['omniauth.auth']
  end

end
