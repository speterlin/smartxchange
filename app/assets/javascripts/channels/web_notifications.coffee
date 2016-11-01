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
    if (typeof data['posts_notifications'] != 'undefined')
      $('.board-header a')[0].innerHTML = if data['posts_notifications'] > 0 then "Boards (#{data['posts_notifications']})" else "Boards"
    if (typeof data['boards_notifications'] != 'undefined')
      for k,v of data['boards_notifications']
        $('#board-'+k+'-header a')[0].innerHTML = if v[1] > 0 then "#{v[0]} (#{v[1]})" else "#{v[0]}"
    if (typeof data['total_notifications'] != 'undefined')
      $('title')[0].innerHTML = if data['total_notifications'] > 0 then "(#{data['total_notifications']}) smartXchange" else "smartXchange"
    $('#chatAudio')[0].play() if data['sound']
    # hack job to refresh page if user is on the chat room / index page, maybe refactor later
    if $('#chat-rooms').length
      location.reload();
