class PostsController < ApplicationController
  include UsersHelper
  include PostsHelper
  include BoardsHelper

  before_action :vote_limit, only: [:upvote, :downvote]
  before_action :post_limit, only: [:create]
  before_action :correct_post?, only: [:update, :destroy]
  after_action -> { board_mark_read(@post.board) }, except: [:followers]

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      # in future may use js along with json to assign values to post.votes_count and post.votes_value_sum
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
    @post = Post.find(params[:id])
    if @post.update(post_params)
      post_create_notifications(@post, @post)
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
    @post = Post.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.js
    end
  end

  def upvote
    @post = Post.includes(:votes).find(params[:id])
    vote = Vote.new(value: 1, owner_id: current_user.id)
    @post.votes << vote
    @up_votes = @post.votes.sum(:value)
    post_create_follow(@post, current_user)
    post_create_notifications(vote, @post)
    respond_to do |format|
      format.js
    end
  end

  def downvote
    @post = Post.includes(:votes).find(params[:id])
    vote = Vote.new(value: -1, owner_id: current_user.id)
    @post.votes << vote
    @up_votes = @post.votes.sum(:value)
    post_destroy_follow(@post, current_user)
    post_create_notifications(vote, @post)
    respond_to do |format|
      format.js
    end
  end

  def follow
    @post = Post.find(params[:id])
    follow = post_create_follow(@post, current_user)
    post_create_notifications(follow, @post)
    respond_to do |format|
      format.js
    end
  end

  def unfollow
    @post = Post.find(params[:id])
    follow = post_destroy_follow(@post, current_user)
    post_create_notifications(follow, @post)
    respond_to do |format|
      format.js
    end
  end

  def followers
    @post = Post.find(params[:id])
    @followers = @post.followers
    respond_to do |format|
      format.js
    end
  end

  private

  def post_params
    params.require(:post).permit(:content, :board_id, :category, :location, :url)
  end

  def vote_limit
    # limit to 10 votes per 24 hour time period
    @limit = 10
    if current_user.votes.count >= @limit && current_user.votes.order(created_at: :desc).limit(@limit).last.created_at > 24.hours.ago
      respond_to do |format|
        format.js {render "vote_limit"}
      end
      return false
    end
    true
  end

  def post_limit
    @limit = 5
    if current_user.posts.count >= @limit && current_user.posts.order(created_at: :desc).limit(@limit).last.created_at > 24.hours.ago
      respond_to do |format|
        format.js {render "post_limit"}
      end
      return false
    end
    true
  end

  def correct_post?
    post = Post.find(params[:id])
    unless post.owner == current_user
      flash[:error] = "Unauthorized access"
      redirect_to root_path
    end
  end

end
