require 'test_helper'

class BoardsControllerTest < ActionDispatch::IntegrationTest

  setup do
    # need to export aws variables as well
    @user = User.create!(email: 'speterlin12@gmail.com', password: 'password', name: 'Sebastian Peterlin', language: 'Spanish', language_level: 3, title: "Co-founder of smartXchange, IMBA 2016 Candidate at IE Business School", image: File.open("app/assets/images/Sebastian_Peterlin professional.jpg"), age: 27, nationality: "American")
    @u1 = User.create!(email: 'example1@gmail.com',password: 'password', name: 'Patsy Purdy', language: 'Spanish', language_level: 4, title: "English teacher, Masters in Communications graduate", image: File.open("app/assets/images/Patsy Purdy.jpg"), age: 26, nationality: "Algerian")
    @u2 = User.create!(email: 'example2@gmail.com',password: 'password', name: 'Abigale Jacobson', language: 'French', language_level: 5, title: "Dentistry student at Complutense University of Madrid", image: File.open("app/assets/images/Abigale Jacobson.jpg"), age: 24, nationality: "Danish")
    @u3 = User.create!(email: 'example3@gmail.com',password: 'password', name: 'Coty Smitham', language: 'German', language_level: 2, title: "PhD in Mathematical Science at Complutense University of Madrid", image: File.open("app/assets/images/Coty Smitham.jpg"), age: 28, nationality: "Canadian")
    @board = Board.create!(title: 'Example', description: 'A board for those looking to learn and practice Spanish. A board where you can post about potential language exchange meetups, tutoring offers, your projects (such as Kickstarter projects), links to your work (such as art, design, development), and educational, interesting, or other material. You can upvote or downvote a post (making someone\'s or your own post more popular), comment on a post, and follow a post so that you receive all notifications for that post. You are limited to 5 posts, 10 votes, and 10 comments per 24 hour period :).')
    @post = Post.create!(content: 'example post', owner_id: @user.id, board_id: @board.id, category: 'Interest')
    @post.followers << @u1
    @post.followers << @u2
  end

  test "when there is a new comment post owner and followers are notified" do
    post "/session", :user => {:email => @u3.email, :password => 'password'}
    assert_difference('Notification.count', 3) do
      post "/comments", params: { comment: { content: 'example comment', commentable_type: 'Post', commentable_id: @post.id} }
    end
    assert @user.posts_notifications.count == 1
    assert @u1.posts_notifications.count == 1
    assert @u2.posts_notifications.count == 1
  end

  test "when a follower comments on a post he/she is not notified" do
    post "/session", :user => {:email => @u2.email, :password => 'password'}
    assert_difference('Notification.count', 2) do
      post "/comments", params: { comment: { content: 'example comment', commentable_type: 'Post', commentable_id: @post.id} }
    end
    assert @user.posts_notifications.count == 1
    assert @u1.posts_notifications.count == 1
    assert_not @u2.posts_notifications.count == 1
  end

  test "when an owner comments on a post he/she is not notified" do
    post "/session", :user => {:email => @user.email, :password => 'password'}
    assert_difference('Notification.count', 2) do
      post "/comments", params: { comment: { content: 'example comment', commentable_type: 'Post', commentable_id: @post.id} }
    end
    assert_not @user.posts_notifications.count == 1
    assert @u1.posts_notifications.count == 1
    assert @u2.posts_notifications.count == 1
  end

  test "when there is a new vote post owner and followers are notified and person becomes a follower" do
    post "/session", :user => {:email => @u3.email, :password => 'password'}
    assert_difference('Notification.count', 3) do
      post "/posts/#{@post.id}/upvote"
    end
    assert @user.posts_notifications.count == 1
    assert @u1.posts_notifications.count == 1
    assert @u2.posts_notifications.count == 1
    assert @u3.followed_posts.include?(@post)
  end

  test "when there are multiple new votes only one new notification is created for post owner and followers" do
    post "/session", :user => {:email => @u3.email, :password => 'password'}
    assert_difference('Notification.count', 3) do
      post "/posts/#{@post.id}/upvote"
      post "/posts/#{@post.id}/upvote"
    end
    assert @user.posts_notifications.count == 1
    assert @u1.posts_notifications.count == 1
    assert @u2.posts_notifications.count == 1
  end

end
