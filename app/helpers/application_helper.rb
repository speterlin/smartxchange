module ApplicationHelper
  def bootstrap_class_for(flash_type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(_opts = {})
    flash.map do |msg_type, message|
      content_tag(:div, class: "alert #{bootstrap_class_for(msg_type)} alert-dismissible fade show", role: "alert") do # message,
        content_tag(:button, nil, class: "btn-close", data: { bs_dismiss: 'alert' }, 'aria-label': 'Close') + # tag.button , 'x', turbo: false
        sanitize(message, tags: %w[a], attributes: %w[href]) #
      end
    end.join.html_safe
  end

  # maybe refactor - but probably not, this and #num_to_month could be in users_helper.rb so don't have to include application_helper.rb in user_mailer.rb
  def a_or_an(string)
    ['a','e','i','o','u'].include?(string[0].downcase) ? 'an' : 'a'
  end

  def num_to_month(num)
    return 'january' if num == 1
    return 'february' if num == 2
    return 'march' if num == 3
    return 'april' if num == 4
    return 'may' if num == 5
    return 'june' if num == 6
    return 'july' if num == 7
    return 'august' if num == 8
    return 'september' if num == 9
    return 'october' if num == 10
    return 'november' if num == 11
    return 'december' if num == 12
  end

end
