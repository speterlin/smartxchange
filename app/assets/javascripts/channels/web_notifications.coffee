App.web_notifications = App.cable.subscriptions.create "WebNotificationsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    console.log('web_notifications - connected')

  disconnected: ->
    # Called when the subscription has been terminated by the server
    console.log('web_notifications - disconnected')

  received: (data) ->
    console.log('web_notifications - received')

    if typeof data['chat_rooms_notifications'] isnt 'undefined'
      el = $('#chat-rooms-header a')[0]
      if el?
        el.innerHTML = if data['chat_rooms_notifications'] > 0 then "Conversations (#{data['chat_rooms_notifications']})" else "Conversations"

    if typeof data['boards_notifications_count'] isnt 'undefined'
      boards_notifications_count = 0
      for k,v of data['boards_notifications_count']
        el = $('#board-'+k+'-header')[0]
        if el?
          board_title = el.innerHTML.match(/\w+(\s+\w+)?/)?[0] or ''
          el.innerHTML = "#{board_title} (#{v})"
          $('#board-'+k+'-header').css("color", "yellow")
          boards_notifications_count += v
      el = $('.boards-header a')[0]
      if el?
        el.innerHTML = if boards_notifications_count > 0 then "Boards (#{boards_notifications_count})" else "Boards"
      $('.boards-header .dropdown-toggle')?.css("color", "yellow")

    if typeof data['total_notifications_count'] isnt 'undefined'
      el = $('title')[0]
      if el?
        el.innerHTML = if data['total_notifications_count'] > 0 then "(#{data['total_notifications_count']}) smartXchange" else "smartXchange"

    $('#chatAudio')[0]?.play() if data['sound']

    if $('#chat-rooms').length
      location.reload()
