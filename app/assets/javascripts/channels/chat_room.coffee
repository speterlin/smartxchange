jQuery(document).on 'turbolinks:load', ->
  $messages = $('#messages')
  $title = $('title')[0]
  if $('#messages').length
    messages_to_bottom = -> $messages.scrollTop($messages.prop("scrollHeight"))

    messages_to_bottom()

    App.chat = App.cable.subscriptions.create {
        channel: "ChatRoomChannel"
        chat_room_id: $messages.data('chat-room-id')
      },

      connected: ->
        console.log('chatroom - connected')
        messages_to_bottom()

      disconnected: ->
        console.log('chatroom - disconnected')

      received: (data) ->
        console.log('chatroom - received')
        $last_message = $("#messages .message").last()
        $new_message = $(data['message'])
        # to prevent repeat messages broadcasted may need to refactor later
        if $last_message.data('message-id') != $new_message.data('message-id')
          sender_id = $new_message.data('sender-id')
          current_user_id = parseInt($('meta[name=user-id]').attr("content"))
          if current_user_id != sender_id
            $new_message.removeClass("self").addClass("other")
          $messages.append($new_message)
        messages_to_bottom()

      send_message: (message, chat_room_id) ->
        console.log('chatroom - send_message')
        @perform 'send_message', message: message, chat_room_id: chat_room_id

    $('#new_message').submit (e) ->
      $this = $(this)
      textarea = $this.find('#message-body')
      if $.trim(textarea.val()).length >= 1
        App.chat.send_message textarea.val(), $messages.data('chat-room-id')
        textarea.val('')
      e.preventDefault()
      return false
    # refactor maybe can combine these two in 'keypress click method'
    $(document).on 'keypress', (event) ->
      if event.keyCode is 13
        $('#new_message').submit()
        event.preventDefault()
    $('.send-message').on 'click', (event) ->
      $('#new_message').submit()
      event.preventDefault()
