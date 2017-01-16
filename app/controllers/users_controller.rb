require 'will_paginate/array'
class UsersController < ApplicationController
  include UsersHelper

  skip_before_action :require_signed_in!, only: [:new, :create, :email_match]
  before_action :correct_user?, only: [:update, :destroy]
  # before_action :indiegogo_campaign, only: [:create]

  def new
    @user_count = User.all.count - (User.all.count % 10)
    @jobs_offered_count = Post.where(category: "Jobs-Offered").count
    if signed_in?
      redirect_to get_user_board_path(current_user)
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
    @user_count = User.all.count - (User.all.count % 10)
    @jobs_offered_count = Post.where(category: "Jobs-Offered").count
    render :new
  end

  def index
    if params[:search]
      original_search = params[:search].downcase
      search = params[:search].downcase
      @users = User.includes(:linkedin)
      if search.scan(/tutor|teacher/).any?
        search.slice!(search.scan(/tutor|teacher/)[0])
        search = search.strip
        @users = @users.where(tutor: true)
      end
      # maybe refactor, seperating language and language level from rest of search string, stripping white space, and performing search only on the remaining values for generic fields
      if search.scan(/spanish|italian|english|french|german/).any? && search.scan(/[a-c][1-2]/).any?
        language = /spanish|italian|english|french|german/.match(search)[0]
        search.slice!(language)
        levels = search.scan(/[a-c][1-2]/)
        # removing levels from search string
        levels.each {|level| search.slice!(level) }
        ratings = levels.map {|level| user_convert_language_level_to_rating(level)}
        search = search.strip
        # need references to make it work, maybe refactor later and include and (language and language_level match)
        @users = @users.where('lower(name) LIKE :search OR cast(age as text) LIKE :search OR lower(title) LIKE :search OR lower(location) LIKE :search OR lower(linkedins.industry) LIKE :search OR lower(linkedins.summary) LIKE :search OR (lower(language) LIKE :language AND language_level IN (:ratings))', search: "%#{search.empty? ? original_search : search}%", language: language, ratings: ratings).references(:linkedin).paginate(page: params[:page], per_page: 12)
      else
        @users = @users.where('lower(name) LIKE :search OR cast(age as text) LIKE :search OR lower(title) LIKE :search OR lower(location) LIKE :search OR lower(linkedins.industry) LIKE :search OR lower(linkedins.summary) LIKE :search OR lower(nationality) LIKE :search', search: "%#{search}%").references(:linkedin).paginate(page: params[:page], per_page: 12)
      end
    else
      @users = current_user.sort_method.paginate(page: params[:page], per_page: 12)
    end
  end

  def show
    @user = User.find(params[:id])
    @chat_room = ChatRoom.new
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # maybe refactor so array isn't generated everytime
      random_match = @user.sort_method[0..24].sample
      messages = ["Now it's time for some networking", "Bored? Post something to the Board and see how many votes it can get :)", "Have you tried messaging <a href=\"#{user_path(random_match)}\">#{random_match.name}, #{random_match.title}</a>?"]
      flash[:success] = "Profile updated! " + messages.sample
      redirect_to user_path(@user)
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to '/users/new', notice: "User deleted"
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

  def email_match
    @user = User.find(params[:user_id])
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
    params.require(:user).permit(:password, :email, :name, :age, :title, :language, :language_level, :image, :nationality, :location, interests: [])
  end

end
