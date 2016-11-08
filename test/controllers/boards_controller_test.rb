require 'test_helper'

class BoardsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @post = Post.first
    @post.followers << User.second
    @post.followers << User.third
  end

  test "when there is a new comment post owner and followers are notified" do
    post "/session", :user => {:email => User.fourth.email, :password => 'password'}
    assert_difference('Notification.count', 3) do
      post "/comments", params: { comment: { content: 'example comment', commentable_type: 'Post', commentable_id: @post.id} }
    end
    assert User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert User.third.posts_notifications.count == 1
  end

  test "when a follower comments on a post the post owner and followers are notified but he/she is not notified" do
    post "/session", :user => {:email => User.third.email, :password => 'password'}
    assert_difference('Notification.count', 2) do
      post "/comments", params: { comment: { content: 'example comment', commentable_type: 'Post', commentable_id: @post.id} }
    end
    assert User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert_not User.third.posts_notifications.count == 1
  end

  test "when an owner comments on a post he/she is not notified but followers are notified" do
    post "/session", :user => {:email => User.first.email, :password => 'password'}
    assert_difference('Notification.count', 2) do
      post "/comments", params: { comment: { content: 'example comment', commentable_type: 'Post', commentable_id: @post.id} }
    end
    assert_not User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert User.third.posts_notifications.count == 1
  end

  test "when there is a new upvote post owner and followers are notified and person becomes a follower" do
    post "/session", :user => {:email => User.fourth.email, :password => 'password'}
    assert_difference('Notification.count', 3) do
      post "/posts/#{@post.id}/upvote"
    end
    assert User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert User.third.posts_notifications.count == 1
    assert User.fourth.followed_posts.include?(@post)
  end

  test "when there is a new downvote post owner and followers are notified and person is removed as follower" do
    post "/session", :user => {:email => User.third.email, :password => 'password'}
    assert_difference('Notification.count', 2) do
      post "/posts/#{@post.id}/downvote"
    end
    assert User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert_not User.third.posts_notifications.count == 1
    assert_not User.third.followed_posts.include?(@post)
  end

  test "when there are multiple new votes only one new notification is created for post owner and followers" do
    post "/session", :user => {:email => User.fourth.email, :password => 'password'}
    assert_difference('Notification.count', 3) do
      post "/posts/#{@post.id}/upvote"
      post "/posts/#{@post.id}/upvote"
    end
    assert User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert User.third.posts_notifications.count == 1
  end

  test "when there is a new follow request post owner and followers are notified" do
    post "/session", :user => {:email => User.fourth.email, :password => 'password'}
    assert_difference('Notification.count', 3) do
      post "/posts/#{@post.id}/follow"
    end
    assert User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert User.third.posts_notifications.count == 1
  end

  test "when there is an unfollow request post owner and followers are notified" do
    post "/session", :user => {:email => User.third.email, :password => 'password'}
    assert_difference('Notification.count', 2) do
      post "/posts/#{@post.id}/unfollow"
    end
    assert User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
  end

  test "when there is a post update followers are notified but not post owner" do
    post "/session", :user => {:email => User.first.email, :password => 'password'}
    assert_difference('Notification.count', 2) do
      patch "/posts/#{@post.id}", :post => {content: "edit post"}
    end
    assert_not User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert User.third.posts_notifications.count == 1
  end

  test "only allow post owner to update post" do
    post "/session", :user => {:email => User.second.email, :password => 'password'}
    patch "/posts/#{@post.id}", :post => {content: "edit post"}
    assert_redirected_to root_path
    assert_equal flash[:error], "Unauthorized access"
  end

  test "only allow comment owner to update comment" do
    post "/session", :user => {:email => User.second.email, :password => 'password'}
    patch "/comments/#{Comment.first.id}", :comment => {content: "edit comment"}
    assert_redirected_to root_path
    assert_equal flash[:error], "Unauthorized access"
  end

  test "only allowed to post 5 times" do
    post "/session", :user => {:email => User.second.email, :password => 'password'}
    assert_difference('Post.count', 5) do
      5.times do
        post "/posts", post: {content: 'example', board_id: 1, category: 'Interest'}
      end
    end
    assert_difference('Post.count', 0) do
      post "/posts", post: {content: 'example', board_id: 1, category: 'Interest'}
    end
  end

  test "only allowed to vote 10 times" do
    post "/session", :user => {:email => User.first.email, :password => 'password'}
    assert_difference('Vote.count', 10) do
      10.times do
        post "/posts/#{@post.id}/upvote"
      end
    end
    assert_difference('Vote.count', 0) do
      post "/posts/#{@post.id}/upvote"
    end
  end

  test "only allowed to comment 10 times" do
    post "/session", :user => {:email => User.second.email, :password => 'password'}
    assert_difference('Comment.count', 10) do
      10.times do
        post "/comments", :comment => {content: "new comment", commentable_type: Post, commentable_id: 1}
      end
    end
    assert_difference('Comment.count', 0) do
      post "/comments", :comment => {content: "new comment", commentable_type: Post, commentable_id: 1}
    end
  end

  test "when there is an unread board board header color changes to yellow" do
    post "/session", :user => {:email => User.third.email, :password => 'password'}
    post "/posts/#{@post.id}/upvote"
    delete "/session"
    post "/session", :user => {:email => User.fourth.email, :password => 'password'}
    follow_redirect!
    assert_select "a.dropdown-toggle", {style: "color: yellow"}
  end

end
