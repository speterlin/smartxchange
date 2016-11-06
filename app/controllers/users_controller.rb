require 'will_paginate/array'
class UsersController < ApplicationController
  include UsersHelper

  skip_before_action :require_signed_in!, only: [:new, :create, :email_match]
  before_action :correct_user?, only: [:update, :destroy]

  def new
    @user_count = User.all.count - (User.all.count % 10)
    redirect_to users_path if signed_in?
  end

  def create
    @user = User.new(user_params)
    if verify_recaptcha(model: @user) && @user.save
      sign_in!(@user)
      welcome_new(@user)
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      @user_count = User.all.count - (User.all.count % 10)
      render :new
    end
  end

  def index
    if params[:search]
      search = params[:search].downcase
      # maybe refactor, seperating language and language level from rest of search string, stripping white space, and performing search only on the remaining values for generic fields
      if search.scan(/[a-c][1-2]/).any? && search.scan(/spanish|italian|english|french|german/).any?
        original_search = search
        levels = search.scan(/[a-c][1-2]/)
        levels.each {|level| search.slice!(level) }
        ratings = levels.map {|level| user_convert_language_level_to_rating(level)}
        language = /spanish|italian|english|french|german/.match(search)[0]
        search.slice!(language)
        search = search.strip
        # need references to make it work, maybe refactor later
        @users = User.includes(:linkedin).where('lower(name) LIKE :search OR cast(age as text) LIKE :search OR lower(title) LIKE :search OR lower(location) LIKE :search OR (lower(language) LIKE :language AND language_level IN (:ratings)) OR lower(linkedins.industry) LIKE :search OR lower(linkedins.summary) LIKE :search', search: "%#{search.empty? ? "original_search" : search}%", language: language, ratings: ratings).references(:linkedin).paginate(page: params[:page], per_page: 12)
        @users = @users.where(tutor: true) if search.scan(/tutor|teacher/).any?
      else
        @users = User.includes(:linkedin).where('lower(name) LIKE :search OR cast(age as text) LIKE :search OR lower(title) LIKE :search OR lower(location) LIKE :search OR lower(nationality) LIKE :search OR lower(linkedins.industry) LIKE :search OR lower(linkedins.summary) LIKE :search', search: "%#{search}%").references(:linkedin).paginate(page: params[:page], per_page: 12)
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
      @random_match = @user.sort_method[0..24].sample
      messages = ["Now it's time for some networking", "Bored? Post something to the Board and see how many votes it can get :)", "Have you tried messaging <a href=\"#{user_path(@random_match)}\">#{@random_match.name}, #{@random_match.title}</a>?"]
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
      flash[:success] = "#{@match.name} notified :)"
      UserMailer.notify_match(@user, @match).deliver_later
    else
      flash[:error] = "Either you're token is incorrect or it has expired"
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :email, :name, :age, :title, :language, :language_level, :image, :nationality, :location)
  end

end
