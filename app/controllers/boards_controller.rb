class BoardsController < ApplicationController
  include UsersHelper
  include PostsHelper
  include BoardsHelper

  before_action :only_premium_or_admin_access_to_smart_jobs

  def show
    @board = Board.find_by_title(board_capitalize(params[:id]))
    if @board.id == 9
      # not sure why we need uniq, prob refactor
      @posts = Post.uniq.tagged_with(params[:tag])
    else
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
    end
    # probably need to refactor this
    if (@board.id == 2 || @board.id == 9) && current_user.premium_or_admin?
      @jobs_offered_posts = @posts.select {|post| post.category == 'Jobs-Offered'}
      @jobs_wanted_posts = @posts.select {|post| post.category == 'Jobs-Wanted'}
    end
    if @board.id != 2
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
    elsif board_has_unread?(@board, current_user)
      # if board has unread get most recently updated post and the most recent notification for that post
      @notification = Notification.where(notifiable: @board.posts.first).last ? Notification.where(notifiable: @board.posts.first).last : Notification.new(notified_id: current_user.id, notifier_id: current_user.id, notifiable_type: @board.posts.first.class.name, notifiable_id: @board.posts.first.id, sourceable_type: @board.posts.first.class.name, sourceable_id: @board.posts.first.id)
      board_mark_read(@board)
    end
  end

  private

  def only_premium_or_admin_access_to_smart_jobs
    # maybe refactor the "2"
    if !current_user.premium_or_admin? && params[:id] == "smart jobs"
      flash[:notice] = "Must be a <a href=\"#{about_path}#premium\">Premium</a> user to view the Smart Jobs Board"
      redirect_to root_path and return
    end
  end

end
