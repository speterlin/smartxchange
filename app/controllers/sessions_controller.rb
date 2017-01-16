class SessionsController < ApplicationController

  skip_before_action :require_signed_in!, only: [:new, :create, :create_linkedin, :new_linkedin, :existing_linkedin]
  # before_action :indiegogo_campaign, only: [:new_linkedin]
  # probably need to refactor class variable at some point
  @@existing = false
  @@add = false
  @@update = false

  def new
    redirect_to users_path if signed_in?
  end

  def create
    # maybe refactor find_by_credentials, need all these is_a?(User) because method can return just an email as well
    @user = User.find_by_credentials(params[:user])
    if @user.is_a?(User) && @user.activated?
      sign_in!(@user)
      normal_sign_in
    # maybe refactor, this is repeated below
    elsif @user.is_a?(User) && !@user.activated?
      flash[:error] = "User not activated, please check your email and activate account"
      redirect_to login_path and return
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

  def existing_linkedin
    @@existing = true
    redirect_to '/auth/linkedin'
  end

  def add_linkedin
    @@add = true
    redirect_to '/auth/linkedin'
  end

  def update_linkedin
    @@update = true
    redirect_to '/auth/linkedin'
  end

  def delete_linkedin
    current_user.linkedin.destroy
    current_user.update(
      provider: "",
      uid: ""
    )
    redirect_to user_url(current_user)
  end

  def create_linkedin
    # maybe refactor because of inability to display errors with adding and updating
    if @@add
      current_user.add_with_omniauth(auth_hash)
      flash[:success] = "Linkedin added to profile"
      @@add = false
      redirect_to user_url(current_user) and return
    end
    if @@update
      current_user.update_with_omniauth(auth_hash)
      flash[:success] = "Linkedin information updated"
      @@update = false
      redirect_to user_url(current_user) and return
    end

    @user = User.where(:provider => auth_hash['provider'],
                      :uid => auth_hash['uid'].to_s).first
    # need to refactor later, some repeat code, added downcase in case linkedin's api doesn't downcase it already
    if !@user && User.where(:email => auth_hash['info']['email'].downcase).first # register or sign in with Linkedin and email taken without Linkedin integration
      flash[:error] = "User with this email already exists, please log in and add Linkedin to your profile"
      redirect_to login_path and return
    elsif !@user && !@@existing # register with linkedin and no linkedin account linked
      @user = User.create_with_omniauth(auth_hash)
      flash[:success] = "Please check your email (registered with Linkedin) for account activation. If you do not see the email please check your spam and promotion mailboxes."
      UserMailer.account_activation(@user).deliver_later
      redirect_to signup_path and return
    elsif @user && !@@existing # register with linkedin and existing linkedin account
      flash[:error] = "Linkedin account already registered with smartXchange, please login with your Linkedin"
      redirect_to login_path and return
    elsif !@user && @@existing # sign in with Linkedin and no Linkedin account linked
      @@existing = false
      flash[:error] = "No Linkedin account registered with smartXchange, please register"
      redirect_to signup_path and return
    end # @user && @@existing, sign in with linkedin and account exists
    @@existing = false
    unless @user.activated?
      flash[:error] = "User not activated, please check your email (registered with Linkedin) and activate account"
      redirect_to login_path and return
    end
    sign_in!(@user)
    normal_sign_in
  end

  protected

  def auth_hash
    # maybe add something here about returning if no auth_hash
    request.env['omniauth.auth']
  end

end
