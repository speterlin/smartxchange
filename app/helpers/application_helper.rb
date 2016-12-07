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

  def photo_from_content(content)
    http_url = /http*[^\s]+/.match(content)[0]
    if !Nokogiri::HTML(open(http_url)).css("meta[property='og:image']").blank?
      photo_url = Nokogiri::HTML(open(http_url)).css("meta[property='og:image']").first.attributes["content"]
      return URI.parse(photo_url)
    else
      return nil
    end
  end

end
