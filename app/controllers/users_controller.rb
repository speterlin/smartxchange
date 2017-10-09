require 'will_paginate/array'
class UsersController < ApplicationController
  include UsersHelper

  skip_before_action :require_signed_in, only: [:new, :create, :email_match]
  before_action :correct_user?, only: [:update, :destroy, :remove_image!, :delete_linkedin!]
  before_action :require_admin?, only: [:active, :map]
  # before_action :premium_subscription, only: [:create]

  def new
    if signed_in?
      redirect_to board_path(Board.find_by_title(current_user.language))
    else
      @user_count = User.all.count - (User.all.count % 100)
      @jobs_offered_count = Post.where(category: "Jobs-Offered").count
    end
  end

  def create
    @user = User.new(user_params)
    if verify_recaptcha(model: @user) && @user.save
      flash.now[:success] = "Please check your email for account activation. If you do not see the email please check your spam and promotion mailboxes."
      UserMailer.account_activation(@user).deliver_later
      @user = nil
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
    end
    @user_count = User.all.count - (User.all.count % 100)
    @jobs_offered_count = Post.where(category: "Jobs-Offered").count
    render :new
  end

  def index
    if params[:search]
      # maybe refactor, at the moment does not allow search across multiple language levels, i.e. 'Spanish b1 b2', could do this with 'or' operator
      # can refactor, add boosts, conversions (with searchjoy), autocomplete, custom search, highlight, boost_by_distance or within a geoshape, performance (persistent http connections, ...), routing - all on https://github.com/ankane/searchkick
      # performs misspelling search if less than 2 results without misspellings, can do misspellings after a certain number of characters (like prefix length), can add exclude_queries
      @users = User.search(params[:search], misspellings: {below: 2, prefix_length: 2}).results.paginate(page: params[:page], per_page: 12)
    else
      @users = current_user.sort_method.paginate(page: params[:page], per_page: 12)
    end
  end

  def show
    @user = User.find_by_param(params[:id])
    @materials = @user.materials if @user.materials
  end

  def update
    @user = User.find_by_param(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated! " + welcome_messages(@user).sample
      redirect_to user_path(@user)
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def destroy
    User.find_by_param(params[:id]).destroy
    redirect_to new_user_path, notice: "User deleted"
  end

  # maybe refactor and move some code to the model
  def remove_image!
    @user = User.find_by_param(params[:id])
    @user.update_attributes(:remove_image => true)
    flash[:success] = "Image removed!"
    redirect_to user_path(@user)
  end

  def delete_linkedin!
    current_user.delete_omniauth!
    redirect_to user_path(current_user)
  end

  # maybe refactor these two to be in a frontend framework or move to protected
  def all
    @users = User.all.includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def active
    @users = User.where(active: true).includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def chat_bots
    @users = User.where(id: 6).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def tutors
    @users = User.where(tutor: true).includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  # may get rid of these
  def spanish
    @users = User.where(language: 'Spanish').includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def italian
    @users = User.where(language: 'Italian').includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def english
    @users = User.where(language: 'English').includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def french
    @users = User.where(language: 'French').includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def german
    @users = User.where(language: 'German').includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def mandarin_chinese
    @users = User.where(language: 'Mandarin Chinese').includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def map
    @users = User.where.not(latitude: nil)
    render :map
  end

  def exchange
    @users = current_user.sort_exchange.paginate(page: params[:page], per_page: 12)
    render :index
  end

  def email_match
    @user = User.find_by_param(params[:user_id])
    @match = User.find(params[:match_id])
    if @user.matches_token == params[:matches_token] && @user.matches_sent_at > 24.hours.ago
      flash.now[:success] = "#{@match.name} notified :)"
      UserMailer.notify_match(@user, @match).deliver_later
    else
      flash.now[:error] = "Either you're token is incorrect or it has expired"
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :email, :name, :birthdate, :title, :language, :language_level, :nationality, :terms, :image, :location, interests: [])
  end

  def require_admin?
    unless current_user.admin?
      flash[:error] = "Must be admin user to access this page"
      redirect_to root_path
    end
  end

end
