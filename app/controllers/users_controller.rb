require 'will_paginate/array'
class UsersController < ApplicationController

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
      user_email, user_password = user_params[:email].downcase, user_params[:password]
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
    elsif params[:search]
      # maybe refactor, at the moment does not allow search across multiple language levels, i.e. 'Spanish b1 b2', could do this with 'or' operator, maybe add includes(:linkedin)
      # can refactor, add boosts, conversions (with searchjoy), autocomplete, custom search, highlight, boost_by_distance or within a geoshape, performance (persistent http connections, ...), routing - all on https://github.com/ankane/searchkick
      # performs misspelling search if less than 2 results without misspellings, can do misspellings after a certain number of characters (like prefix length), can add exclude_queries
      @users = User.search(params[:search], misspellings: {below: 2, prefix_length: 2}, includes: [:linkedin]).results.paginate(page: params[:page], per_page: 12)
    else
      # user.rb#sort_method has .includes(:linkedin)
      @users = current_user.sort_method.paginate(page: params[:page], per_page: 12)
    end
  end

  # need to refactor, currently making 3 calls to User.search for every autocomplete, would like to search the 3 fields and return the matching
  def autocomplete
    render json: autocomplete_language_and_level + autocomplete_location
  end

  def autocomplete_usertag
    # probably refactor, not great regex, could also use =~ for if statement
    render json: User.search(params[:query], {
      fields: ["name"],
      # match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 2}
    }).map{|user| user.name.downcase.prepend('@').split(' ').join('.')}
  end

  def autocomplete_language_and_level
    p params[:query]
    User.search(params[:query], {
      fields: ["language_and_level"],
      # match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 2}
    }).map(&:language_and_level)
  end

  def autocomplete_location
    User.search(params[:query], {
      fields: ["location"],
      # match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 2}
    }).map(&:location)
  end

  def show
    @user = User.find_by_param(params[:id])
    if @user.nil?
      redirect_to root_path, alert: "User not found"
    else
      @materials = @user.materials.includes(:owner)
      @reviews = @user.reviews.includes(:reviewer)
    end
  end

  def update
    # can only do ||= here and #destroy since #correct_user? called right before, therefore don't have to (cache) load user again
    @user ||= User.find_by_param(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated! " + welcome_messages(@user).sample
      redirect_to user_path(@user)
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      redirect_to user_path(@user)
    end
  end

  def destroy
    @user ||= User.find_by_param(params[:id])
    @user.destroy
    redirect_to new_user_path, notice: "User deleted"
  end

  # maybe refactor and move some code to the model
  def remove_image!
    @user ||= User.find_by_param(params[:id])
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
      redirect_to user_path(@user)
    end
  end

  def all
    @users = User.all.includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def active
    @users = User.where(active: true).includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def exchange
    # user.rb#sort_exchange has .includes(:linkedin)
    @users = current_user.sort_exchange.paginate(page: params[:page], per_page: 12)
    render :index
  end

  def tutors
    @users = User.where(tutor: true).includes(:linkedin).paginate(page: params[:page], per_page: 12)
    render :index
  end

  def map
    @users = User.where.not(latitude: nil)
    render :map
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
