module ApplicationHelper
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat sanitize(message)
            end)
    end
    nil
  end

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
