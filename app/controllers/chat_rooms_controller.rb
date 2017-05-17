class ChatRoomsController < ApplicationController
  include ChatRoomsHelper

  before_action :correct_chat_room?, only: [:show, :destroy]

  def index
    # includes is for chat room helper methods called when listing a chat room
    @chat_rooms = ChatRoom.includes(:notifications, :recipient, :initiator).involving(current_user)
  end

  def new
    @chat_room = ChatRoom.new
  end

  def show
    @chat_room ||= ChatRoom.find(params[:id])
    # probably refactor, in cases where user has conversations and then switches to standard membership and tries to access those conversations
    if @chat_room.person_of_interest_or_chat_bot_or_tutor_and_not_premium_or_admin?
      flash[:error] = @chat_room.errors.full_messages.to_sentence
      redirect_to :back and return
    end
    @messages = @chat_room.messages.includes(:sender)
    @message = Message.new
    @receiver = chat_room_interlocutor(@chat_room, current_user)
    # updating notifications for user as they visit chat room
    chat_room_mark_read(@chat_room, current_user)
    render :show #needed since create action redirects here, needs to know what template to show
  end

  def create
    @chat_room = ChatRoom.between(current_user.id, chat_room_params[:recipient_id], current_user.language).first
    if !@chat_room
      # set up right now so that the title of the chat room is the initiator's
      @chat_room = ChatRoom.create(initiator_id: current_user.id, recipient_id: chat_room_params[:recipient_id], title: current_user.language)
      unless @chat_room.persisted?
        flash[:error] = @chat_room.errors.full_messages.to_sentence
        redirect_to :back and return
      else
        UserMailer.new_conversation(@chat_room).deliver_later(wait_until: 2.minutes.from_now)
      end
    end
    show
  end

  def destroy
    @chat_room = ChatRoom.find(params[:id])
    @chat_room.destroy
    respond_to  do |format|
      format.js
    end
  end

  private

  def chat_room_params
    params.require(:chat_room).permit(:recipient_id)
  end

end
