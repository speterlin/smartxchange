require 'will_paginate/array'
class UsersController < ApplicationController
  include UsersHelper

  skip_before_action :require_signed_in, only: [:new, :create, :email_match]
  before_action :correct_user?, only: [:update, :destroy, :remove_image!]
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
    # maybe refactor and allow for multiple params, for example ?language=French&search=Engineering, and also maybe incorporate into a frontend framework
    if params[:language]
      @users = User.where(language: params[:language]).includes(:linkedin).paginate(page: params[:page], per_page: 12)
    elsif params[:scope]
      # maybe move some of these into their own methods, may be better to write users/tutors and users/all rather than users?scope=tutors
      if params[:scope] == "all"
        @users = User.all.includes(:linkedin).paginate(page: params[:page], per_page: 12)
      elsif params[:scope] == "active"
        @users = User.where(active: true).includes(:linkedin).paginate(page: params[:page], per_page: 12)
      elsif params[:scope] == "chat_bots" #currently unused, may use or take out eventually
        @users = User.where(id: 6).paginate(page: params[:page], per_page: 12)
      elsif params[:scope] == "tutors"
        @users = User.where(tutor: true).includes(:linkedin).paginate(page: params[:page], per_page: 12)
      elsif params[:scope] == "map"
        @users = User.where.not(latitude: nil)
        render :map
      elsif params[:scope] == "exchange"
        @users = current_user.sort_exchange.paginate(page: params[:page], per_page: 12)
      end
    elsif params[:search]
      # maybe refactor, at the moment does not allow search across multiple language levels, i.e. 'Spanish b1 b2', could do this with 'or' operator, maybe add includes(:linkedin)
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

  # maybe refactor, very similar to #update, can't check params[:user][:interests] for situation when user unchecks all
  def update_interests!
    @user = User.find_by_param(params[:id])
    interests = params[:user].nil? ? nil : user_params["interests"].map(&:to_i)
    if @user.update(interests: interests)
      flash[:success] = "Profile updated! " + welcome_messages(@user).sample
      redirect_to user_path(@user)
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      redirect_to :back
    end
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
