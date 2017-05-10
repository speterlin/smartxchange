class SessionsController < ApplicationController

  skip_before_action :require_signed_in!, only: [:new, :create, :add_update_register_login_with_linkedin, :new_linkedin, :login_with_linkedin]
  # before_action :premium_subscription, only: [:new_linkedin]
  # probably need to refactor class variable at some point
  @@login_with_linkedin = false
  @@add_linkedin = false
  @@update_linkedin = false

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

  # maybe get rid of this and just replace with '/auth/linkeidn' in button where its called refactor, also maybe move all of these to user controller
  def new_linkedin
    redirect_to '/auth/linkedin'
  end

  def login_with_linkedin
    @@login_with_linkedin = true
    redirect_to '/auth/linkedin'
  end

  def add_linkedin
    @@add_linkedin = true
    redirect_to '/auth/linkedin'
  end

  def update_linkedin
    @@update_linkedin = true
    redirect_to '/auth/linkedin'
  end

  def delete_linkedin
    current_user.linkedin.destroy
    current_user.update(
      provider: nil,
      uid: nil
    )
    redirect_to user_path(current_user)
  end

  def add_update_register_login_with_linkedin
    @user = User.where(:provider => auth_hash['provider'],
                      :uid => auth_hash['uid'].to_s).first
    # maybe refactor because of inability to display errors with adding and updating, maybe join these if elsif statements with ones below
    if @@add_linkedin
      if @user # if trying to add Linkedin account associated with another account
        flash[:error] = "Linkedin account already registered with another account"
      else # adding Linkedin to account, no associated Linkedin
        current_user.add_with_omniauth(auth_hash)
        flash[:success] = "Linkedin added to profile"
      end
      @@add_linkedin = false
      redirect_to user_path(current_user) and return
    end
    if @@update_linkedin
      if @user
        current_user.update_with_omniauth(auth_hash)
        flash[:success] = "Linkedin information updated"
      else # should never be the case, should only be able to click 'Update with Linkedin' if you have an account
        flash[:error] = "Must have a Linkedin account registered to update your Linkedin"
      end
      @@update_linkedin = false
      redirect_to user_path(current_user) and return
    end
    # need to refactor later, some repeat code, added downcase in case linkedin's api doesn't downcase it already
    if User.where(:email => auth_hash['info']['email'].downcase).first && !@user # register or sign in with Linkedin and email taken without Linkedin integration
      # refactor, precautionary, not very necessary, just reset it in case it's set
      @@login_with_linkedin = false
      flash[:error] = "User with this email already exists, please log in and add Linkedin to your profile"
      redirect_to login_path and return
    end
    if @@login_with_linkedin
      @@login_with_linkedin = false
      if @user # login with Linkedin and user found
        unless @user.activated?
          flash[:error] = "User not activated, please check your email (registered with Linkedin) and activate account"
          redirect_to login_path and return
        end
        sign_in!(@user)
        normal_sign_in
      else # sign in with Linkedin and no Linkedin account linked
        flash[:error] = "No Linkedin account registered with smartXchange, please register"
        redirect_to signup_path and return
      end
    else # register with Linkedin
      if @user # register with linkedin and linkedin account already linked
        flash[:error] = "Linkedin account already registered with smartXchange, please login with your Linkedin"
        redirect_to login_path and return
      else # register with linkedin and no linkedin account linked
        @user = User.create_with_omniauth(auth_hash)
        flash[:success] = "Please check your email (registered with Linkedin) for account activation. If you do not see the email please check your spam and promotion mailboxes."
        UserMailer.account_activation(@user).deliver_later
        redirect_to signup_path and return
      end
    end
  end

  protected

  def auth_hash
    # maybe add something here about returning if no auth_hash
    request.env['omniauth.auth']
  end

end
