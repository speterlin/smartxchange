App.web_notifications = App.cable.subscriptions.create "WebNotificationsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    console.log('web_notifications - connected')

  disconnected: ->
    # Called when the subscription has been terminated by the server
    console.log('web_notifications - disconnected')

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    # Client-side which assumes you've already requested
    console.log('web_notifications - received')

    # may need to refactor this, if variable is not defined, don't change otherwise change
    if (typeof data['chat_rooms_notifications'] != 'undefined')
      $('#chat-rooms-header a')[0].innerHTML = if data['chat_rooms_notifications'] > 0 then "Conversations (#{data['chat_rooms_notifications']})" else "Conversations"
    if (typeof data['boards_notifications_count'] != 'undefined')
      # probably refactor, this variable is not really necessary since if data['boards_notifications_count'] exists then there should always be boards_notifications
      boards_notifications_count = 0
      for k,v of data['boards_notifications_count']
        board_title = $('#board-'+k+'-header a')[0].innerHTML.match(/\w+(\s+\w+)?/)[0]
        $('#board-'+k+'-header a')[0].innerHTML = "#{board_title} (#{v})"
        $('#board-'+k+'-header a').css("color", "yellow")
        boards_notifications_count += v
      $('.boards-header a')[0].innerHTML = if boards_notifications_count > 0 then "Boards (#{boards_notifications_count})" else "Boards"
      # maybe refactor and add precautionary check here, should always be new posts if data['boards_notifications_count'] exists
      $('.boards-header .dropdown-toggle').css("color", "yellow")
    if (typeof data['total_notifications_count'] != 'undefined')
      $('title')[0].innerHTML = if data['total_notifications_count'] > 0 then "(#{data['total_notifications_count']}) smartXchange" else "smartXchange"
    $('#chatAudio')[0].play() if data['sound']
    # hack job to refresh page if user is on the chat room / index page, maybe refactor later
    if $('#chat-rooms').length
      location.reload();
