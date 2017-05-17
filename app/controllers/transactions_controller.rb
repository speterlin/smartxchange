class TransactionsController < ApplicationController

  before_action :user_is_premium_or_admin?, only: [:new, :create]
  before_action :premium_subscription

  def new
    if current_user.has_braintree_info?
      gon.client_token = generate_client_token
    else
      render :new_customer
    end
  end

  def create
    @result = Braintree::Subscription.create(
      payment_method_nonce: params[:payment_method_nonce],
      plan_id: "2"
    )
    if @result.success?
      current_user.subscribe_to_premium
      UserMailer.premium_subscribe(current_user).deliver_later
      redirect_to root_path, notice: "Congratulations! You have successfully subscribed to smartXchange Premium! Please check your email for instructions on what to do next."
    else
      flash.now[:error] = "Something went wrong while processing your subscription. Please try again!"
      gon.client_token = generate_client_token
      render :new
    end
  end

  def new_customer
  end

  def create_customer
    unless customer_params_present?
      flash[:error] = "Please fill out all fields"
      redirect_to :back and return
    end
    result = Braintree::Customer.create(
      first_name: customer_params[:first_name],
      last_name: customer_params[:last_name],
      company: customer_params[:company],
      email: current_user.email,
      phone: customer_params[:phone]
    )
    if result.success?
      current_user.update(braintree_customer_id: result.customer.id)
      redirect_to new_transaction_path
    else
      flash.now[:error] = result.errors
      render :new_customer
    end
  end

  private

  def generate_client_token
    # maybe refactor, shouldn't be called unless user has braintree_customer_id therefore shouldn't throw error
    Braintree::ClientToken.generate(customer_id: current_user.braintree_customer_id)
  end

  def user_is_premium_or_admin?
    redirect_to :back, notice: "User already has Premium Membership or is an Admin" if current_user.premium_or_admin?
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :company, :phone)
  end

  def customer_params_present?
    customer_params.each  do |name, value|
      if value.length == 0
        return false
      end
    end
    true
  end

end
