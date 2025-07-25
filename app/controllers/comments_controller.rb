class CommentsController < ApplicationController
  include PostsHelper
  include BoardsHelper

  before_action :comment_limit, only: [:create]
  before_action :correct_comment?, only: [:update, :destroy]
  after_action -> { board_mark_read(@comment.commentable.board) }

  def create
    Rails.logger.info params.inspect
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      # assuming that the comment is for a post, will have to add code if add comment on a comment
      @post = @comment.commentable
      post_create_follow(@post, current_user)
      post_create_notifications(@comment, @post)
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js {render "errors"}
      end
    end
  end

  def update
    # can only do ||= here and #destroy since #correct_comment? called right before, therefore don't have to (cache) load comment again
    @comment ||= Comment.find(params[:id])
    if @comment.update(comment_params)
      post_create_notifications(@comment, @comment.commentable)
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js {render "errors"}
      end
    end
  end

  def destroy
    @comment ||= Comment.find(params[:id])
    @comment.destroy
    @post = @comment.commentable
    # don't destroy follow if there is still a comment on the post owned by the current user
    post_destroy_follow(@post, current_user) unless @post.comments.pluck(:owner_id).include?(current_user.id)
    respond_to do |format|
      format.js
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :commentable_type, :commentable_id)
  end

  def comment_limit
    @limit = 10
    if current_user.comments.count >= @limit && current_user.comments.order(created_at: :desc).limit(@limit).last.created_at > 24.hours.ago
      respond_to do |format|
        format.js {render "comment_limit"}
      end
      return false
    end
    true
  end

  def correct_comment?
    @comment = Comment.find(params[:id])
    unless @comment.owner == current_user
      flash[:error] = "Unauthorized access"
      redirect_to root_path
    end
  end

end
