class PostsController < ApplicationController
  include PostsHelper
  include BoardsHelper

  before_action :vote_limit, only: [:upvote, :downvote]
  before_action :post_limit, only: [:create]
  before_action :correct_post?, only: [:update, :destroy]
  after_action -> { board_mark_read(@post.board) }, except: [:followers, :autocomplete_hashtag]

  def create
    @post = current_user.posts.new(post_params)
    add_or_update_url(@post, post_params[:content])
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
    add_or_update_url(@post, post_params[:content])
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
    # quick fix, needs to be refactored here and in #downvote, #follow and #unfollow, this way post shows updated_at upon updating, could also use Time.now
    @post.updated_at = vote.updated_at
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
    @post.updated_at = vote.updated_at
    @up_votes = @post.votes.sum(:value)
    # may add this back later: post_destroy_follow(@post, current_user)
    post_create_notifications(vote, @post)
    respond_to do |format|
      format.js
    end
  end

  def follow
    @post = Post.find(params[:id])
    follow = post_create_follow(@post, current_user)
    @post.updated_at = follow.updated_at
    post_create_notifications(follow, @post)
    respond_to do |format|
      format.js
    end
  end

  def unfollow
    @post = Post.find(params[:id])
    follow = post_destroy_follow(@post, current_user)
    # hack here, since follow is destroyed, can't use follow.updated_at, since board is updated we will use that
    @post.updated_at = @post.board.updated_at
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

  def autocomplete_hashtag
    # probably refactor, not great regex, could also use =~ for if statement
    render json: Post.search(params[:query], {
      fields: ["hashtags"],
      # match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 2}
    }).map{|post| post.hashtags.split(" ").map{|hashtag| hashtag.prepend('#')}.join(" ") }
  end

  private

  def post_params
    params.require(:post).permit(:content, :board_id, :category, :location)
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
    @post ||= Post.find(params[:id])
    unless @post.owner == current_user
      flash[:error] = "Unauthorized access"
      redirect_to root_path
    end
  end

  # maybe refactor: only returns first matched url, using regex look-behind and look-ahead to avoid usertags, hashtags and emails, regex doesn't match url if there is / at end, adding a post is currently quite slow don't know if this is the reason (probably image is reason), also have to add http:// (maybe make it https, don't think it matters)to get link to work correctly in _post.html.erb, also if link has neither http(s):// nor www. this method will accept it as link but rails_autolink will not, also don't like passing both post and content to method but only way to work with #update
  def add_or_update_url(post, content)
    url = content.scan(/(?<=\s|^)(?:https?\:\/\/)?(?:www\.)?(?:[-a-z0-9]+\.)+[-a-z0-9]+(?=\s|$)/i)[0]
    url = "http://" + url if url && !url.match(/(?:https?\:\/\/)/i)
    if url && url != post.url
      post.url = url
    end
  end

end
