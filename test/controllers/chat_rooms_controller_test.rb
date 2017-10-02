require 'test_helper'

class ChatRoomsControllerTest < ActionDispatch::IntegrationTest

  setup do
    # make first user premium
    User.first.package = Package.second
  end

  test "can not create new chat room with person of interest for a regular member" do
    post "/session", :user => {:email => User.second.email, :password => 'password'}
    assert_difference('ChatRoom.count', 0) do
      post "/chat_rooms", chat_room: {recipient_id: 5}
    end
    assert_equal flash[:error], "Recipient is a Person of Interest, Chatbot, or Tutor, Premium membership required"
  end

  test "can not create new chat room with tutor for a regular member" do
    post "/session", :user => {:email => User.second.email, :password => 'password'}
    assert_difference('ChatRoom.count', 0) do
      post "/chat_rooms", chat_room: {recipient_id: 7}
    end
    assert_equal flash[:error], "Recipient is a Person of Interest, Chatbot, or Tutor, Premium membership required"
  end

  test "can not create new chat room with chatbot for a regular member" do
    post "/session", :user => {:email => User.second.email, :password => 'password'}
    assert_difference('ChatRoom.count', 0) do
      post "/chat_rooms", chat_room: {recipient_id: 6}
    end
    assert_equal flash[:error], "Recipient is a Person of Interest, Chatbot, or Tutor, Premium membership required"
  end

  test "premium member can create chat room with person of interest or chatbot or tutor" do
    post "/session", :user => {:email => User.first.email, :password => 'password'}
    assert_difference('ChatRoom.count', 1) do
      post "/chat_rooms", chat_room: {recipient_id: 5}
    end
    assert_difference('ChatRoom.count', 1) do
      post "/chat_rooms", chat_room: {recipient_id: 6}
    end
    assert_difference('ChatRoom.count', 1) do
      post "/chat_rooms", chat_room: {recipient_id: 7}
    end
  end

  test "can only access chat room that you are involved in" do
    post "/session", :user => {:email => User.third.email, :password => 'password'}
    get "/chat_rooms/#{ChatRoom.first.id}"
    assert_redirected_to root_path
    assert_equal flash[:error], "Unauthorized access"
  end

  test "if chat room already exists between you and recipient with title you are redirected to the that chat room" do
    post "/session", :user => {:email => User.first.email, :password => 'password'}
    assert_difference('ChatRoom.count', 0) do
      post "/chat_rooms", chat_room: {recipient_id: 2}
    end
    assert_select "div#messages", data: {chat_room_id: 1}
  end

end
