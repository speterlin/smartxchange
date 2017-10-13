class SessionsController < ApplicationController

  skip_before_action :require_signed_in, only: [:new, :create]

  def new
    redirect_to root_path if signed_in?
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
      normal_sign_in!
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

end
