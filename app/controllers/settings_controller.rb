class SettingsController < ApplicationController

  skip_before_action :require_signed_in, only: [:reset_password, :create_password!, :email_subscription, :update_subscription, :activate_account!]
  before_action :correct_user?, except: [:reset_password, :create_password!, :email_subscription, :update_subscription, :activate_account!]

  def show
    @user = User.find_by_param(params[:user_id])
  end

  def reset_password
    redirect_to root_path if signed_in?
  end

  def create_password!
    @user = User.find_by(email: user_params[:email].downcase)
    if @user
      # 6 results in a string length of 8, string length is 4/3 * n
      new_password = SecureRandom.urlsafe_base64(6)
      @user.update!(password: new_password) # bang because this is an important step
      UserMailer.reset_password(@user, new_password).deliver_later
      flash[:success] = "Email sent with password reset instructions"
      redirect_to root_path # maybe refactor this
    # maybe refactor and make this a pop up in the future
    else
      flash[:error] = "No user found with this email address"
      redirect_to reset_password_users_path
    end
  end

  def change_password
    @user = User.find_by_param(params[:user_id])
  end

  def update_password!
    # probably need to refactor this, maybe add token
    @user = User.find_by_param(params[:user_id])
    if @user.try(:is_password?, user_params[:current_password])
      if user_params[:new_password] == user_params[:password_confirmation]
        if @user.update(password: user_params[:new_password])
          flash[:success] = "Password updated"
          redirect_to user_settings_path(@user)
        else
          flash[:error] = @user.errors.full_messages.to_sentence
          redirect_to change_password_user_settings_path(@user)
        end
      else
        flash[:error] = "New password does not match password confirmation"
        redirect_to change_password_user_settings_path(@user)
      end
    else
      flash[:error] = "Password does not match existing password"
      redirect_to change_password_user_settings_path(@user)
    end
  end

  def email_subscription
    if signed_in? && correct_user? #this first to prevent unlikely scenario of person being logged into one account and opening 'Manage Subscriptions' from email associated with another account
      @user = User.find_by_param(params[:user_id])
    elsif params[:id]
      user_id = Rails.application.message_verifier(:unsubscribe).verify(params[:id])
      @user = User.find(user_id)
    else
      flash[:error] = "Must be logged in as correct user or access this link through an email to view this page"
      redirect_to login_path and return
    end
  end

  def update_subscription
    @user = User.find_by_param(params[:user_id])
    if @user.email_subscription.update(email_params)
      redirect_to email_subscription_user_settings_path(@user), notice: 'Email subscription updated'
    else
      flash.now[:alert] = 'There was a problem'
      render :email_subscription
    end
  end

  def activate!
    # could switch this and deactive to @user = User.find(params[:user_id])
    current_user.appear!
    flash[:success] = "You are now browsing in active mode"
    redirect_to user_settings_path(@user)
  end

  def deactivate!
    current_user.disappear!
    redirect_to user_settings_path(@user), notice: "You are now browsing in stealth mode"
  end

  def downgrade
    # maybe refactor and move this method to transactions controller
    customer = Braintree::Customer.find(current_user.braintree_customer_id)
    subscriptions = customer.payment_methods.map(&:subscriptions).flatten
    subscription = subscriptions.select {|s| (s.status == "Active" && s.plan_id == "2")}.first
    Braintree::Subscription.cancel(subscription.id)
    current_user.unsubscribe_to_premium
    UserMailer.premium_unsubscribe(current_user).deliver_later
    redirect_to user_settings_path(@user), notice: "Premium subscription cancelled! You now have the Standard package"
  end

  def activate_account!
    @user = User.find_by(email: params[:email])
    if @user.activation_token == params[:activation_token]
      @user.update!(activated: true) # keep bang here because it's an important step, want it to fail if account is not activated
      sign_in!(@user)
      welcome_new(@user)
    else
      flash.now[:error] = "Activation token does not match or user with this email was not found"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :current_password, :new_password, :password_confirmation)
  end

  def email_params
    params.require(:email).permit(:weekly_notifications, :monthly_update, :language_matches, :notify_match, :new_conversation, :new_message, :peer_review, :notify_review, :unread_board, :unread_jobs, :new_post, :unread_materials, :related_material)
  end

end
