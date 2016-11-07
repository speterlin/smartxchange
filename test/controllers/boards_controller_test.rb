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

  test "when a follower comments on a post he/she is not notified" do
    post "/session", :user => {:email => User.third.email, :password => 'password'}
    assert_difference('Notification.count', 2) do
      post "/comments", params: { comment: { content: 'example comment', commentable_type: 'Post', commentable_id: @post.id} }
    end
    assert User.first.posts_notifications.count == 1
    assert User.second.posts_notifications.count == 1
    assert_not User.third.posts_notifications.count == 1
  end

  test "when an owner comments on a post he/she is not notified" do
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

  test "when there is a new downvote person is removed as follower" do
    post "/session", :user => {:email => User.third.email, :password => 'password'}
    post "/posts/#{@post.id}/downvote"
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

  test "when there is an unread board board header color changes to yellow" do
    post "/session", :user => {:email => User.third.email, :password => 'password'}
    post "/posts/#{@post.id}/upvote"
    delete "/session"
    post "/session", :user => {:email => User.fourth.email, :password => 'password'}
    follow_redirect!
    assert_select "a.dropdown-toggle", {style: "color: yellow"}
  end

end
