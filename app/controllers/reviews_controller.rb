class ReviewsController < ApplicationController

  before_action :correct_user?

  def index
    @user = User.find_by_param(params[:user_id])
    @reviews = @user.reviews
    @created_reviews = @user.created_reviews
  end

  def new
    other_user_id = Rails.application.message_verifier(:peer_review).verify(params[:id])
    @other_user = User.find(other_user_id)
    @chat_room = ChatRoom.find(params[:chat_room_id])
    if Review.between(current_user, @other_user, @chat_room).first
      @review = Review.between(current_user, @other_user, @chat_room).first
      redirect_to edit_user_review_path(current_user, @review) and return
    end
  end

  def create
    # maybe refactor assuming here that reviewable is User, maybe change later if we make chat_room reviewable
    @review = current_user.created_reviews.new(review_params)
    if @review.save
      flash[:success] = "Review submitted"
      UserMailer.notify_review(@review.reviewable, current_user, @review).deliver_later
      redirect_to user_reviews_path(current_user)
    else
      # should never be the case since required fields are autopopulated and non-null, can't go back to new_user_reviews_path since need the id that identifies the other user
      flash[:error] = @review.errors.full_messages.to_sentence + ", please visit link in email to re-open review"
      redirect_to user_reviews_path(current_user)
    end
  end

  def edit
    @review = Review.find(params[:id])
    @other_user = @review.reviewable
    @chat_room = @review.chat_room
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(review_params)
      flash[:success] = "Review updated"
      redirect_to user_reviews_path(current_user)
    else
      flash[:error] = @review.errors.full_messages.to_sentence
      redirect_to edit_user_review(current_user)
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to user_reviews_path(current_user), notice: "Review deleted"
  end

  private

  def review_params
    params.require(:review).permit(:reviewable_type, :reviewable_id, :chat_room_id, :language, :language_level, :comment)
  end

end
