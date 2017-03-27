class SettingsController < ApplicationController

  skip_before_action :require_signed_in!, only: [:reset_password, :create_password, :email_subscription, :update_subscription, :activate_account]
  before_action :correct_user?, except: [:reset_password, :create_password, :update_subscription, :activate_account]

  def show
    @user = User.find(params[:user_id])
  end

  def reset_password
  end

  def create_password
    @user = User.find_by(email: user_params[:email].downcase)
    if @user
      # 6 results in a string length of 8, string length is 4/3 * n
      @new_password = SecureRandom.urlsafe_base64(6)
      @user.update(password: @new_password)
      UserMailer.reset_password(@user, @new_password).deliver_later
      flash[:success] = "Email sent with password reset instructions"
      redirect_to :back
    # maybe make this a pop up in the future
    else
      flash[:error] = "No user found with this email address"
      redirect_to :back
    end
  end

  def change_password
    @user = User.find(params[:user_id])
  end

  def update_password
    # probably need to refactor this, maybe add token
    @user = User.find(params[:user_id])
    if @user.try(:is_password?, user_params[:current_password])
      if user_params[:new_password] == user_params[:password_confirmation]
        if @user.update(password: user_params[:new_password])
          flash[:success] = "Password updated"
          redirect_to user_settings_path(@user)
        else
          flash[:error] = @user.errors.full_messages.to_sentence
          redirect_to :back
        end
      else
        flash[:error] = "New password does not match password confirmation"
        redirect_to :back
      end
    else
      flash[:error] = "Password does not match existing password"
      redirect_to :back
    end
  end

  def email_subscription
    if params[:id]
      user_id = Rails.application.message_verifier(:unsubscribe).verify(params[:id])
    elsif signed_in? && correct_user?
      user_id = params[:user_id]
    else
      flash[:error] = "Must be logged in as correct user or access this link through an email to view this page"
      redirect_to login_path and return
    end
    @user = User.find(user_id)
  end

  def update_subscription
    @user = User.find(params[:user_id])
    if @user.email_subscription.update(email_params)
      redirect_to :back, notice: 'Email subscription changed'
    else
      flash.now[:alert] = 'There was a problem'
      render :email_subscription
    end
  end

  def activate
    # could switch this and deactive to @user = User.find(params[:user_id])
    current_user.appear
    flash[:success] = "You are now browsing in active mode"
    redirect_to :back
  end

  def deactivate
    current_user.disappear
    redirect_to :back, notice: "You are now browsing in stealth mode"
  end

  def downgrade
    # maybe refactor and move this method to transactions controller
    customer = Braintree::Customer.find(current_user.braintree_customer_id)
    subscriptions = customer.payment_methods.map(&:subscriptions).flatten
    subscription = subscriptions.select {|s| (s.status == "Active" && s.plan_id == "2")}.first
    Braintree::Subscription.cancel(subscription.id)
    current_user.unsubscribe_to_premium
    UserMailer.premium_unsubscribe(current_user).deliver_later
    redirect_to :back, notice: "Premium subscription cancelled! You now have the Standard package"
  end

  def activate_account
    @user = User.find_by(email: params[:email])
    if @user.activation_token == params[:activation_token]
      @user.update!(activated: true)
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
    params.require(:email).permit(:weekly_notifications, :monthly_update, :language_matches, :notify_match, :new_conversation, :new_message, :peer_review, :notify_review, :unread_board, :unread_jobs, :new_post)
  end

end
