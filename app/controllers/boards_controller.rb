class BoardsController < ApplicationController
  include UsersHelper
  include PostsHelper
  include BoardsHelper

  before_action :only_premium_access_to_smart_jobs, only: [:show]

  def show
    @board = Board.find(params[:id])
    # refactor sql query, right now orders by sum(value) then updated_at, also not filtering posts based on board, and all comments are for post, group by just v.votable_id (ok in sql but not pg) is faster
    # coalesce because postgres does not return sum of empty column
    @posts = Post.find_by_sql("
      select p.*, v.votable_id, count(v.votable_id) as votes_count, coalesce(sum(v.value),0) as votes_value_sum
      from posts p
      left join votes v on p.id = v.votable_id
      where p.board_id = #{@board.id}
      group by p.id, v.votable_id
      order by votes_value_sum desc, p.updated_at desc")
      # only way to get includes to work on the array returned from the sql statement above, maybe refactor don't need all followers information
      ActiveRecord::Associations::Preloader.new.preload(@posts, [:owner, :comments, {comments: :owner}, :followers])
    if @board.id == 2
      @jobs_offered_posts = @posts.select {|post| post.category == 'Jobs-Offered'}
      @jobs_wanted_posts = @posts.select {|post| post.category == 'Jobs-Wanted'}
    else
      @interest_posts = @posts.select {|post| post.category == 'Interest'}
      @educational_posts = @posts.select {|post| post.category == 'Educational'}
      @tutoring_posts = @posts.select {|post| post.category == 'Tutoring'}
      @meetup_posts = @posts.select {|post| post.category == 'Meetup'}
      @professional_posts = @posts.select {|post| post.category == 'Professional'}
      @other_posts = @posts.select {|post| post.category == 'Other'}
    end

    if user_count_unread_board_notifications(current_user, @board) > 0
      @notification = user_first_unread_board_notification(current_user, @board)
      # maybe refactor this and chat_room_mark_read to notification_mark_read, and delete notification
      post_mark_read(@notification)
    end
    # maybe refactor later, only update user if he/she is viewing unread posts, add +1 to current user due to delay in updating associations through touch
    if board_has_unread?(@board, current_user)
      board_mark_read(@board)
    end
  end

  private

  def only_premium_access_to_smart_jobs
    # maybe refactor the "2"
    if !current_user.premium? && params[:id] == "2"
      flash[:notice] = "Must be a premium user to view theSmart Jobs Board"
      redirect_to users_path and return
    end
  end

end
