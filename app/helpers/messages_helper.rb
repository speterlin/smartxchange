module MessagesHelper

  def message_self_or_other(message, user)
    message.sender == user ? "self" : "other"
  end

  def message_convert_level_to_img(message)
    # The more faded it is the worse the level
    filtered = (1 - message.sender.language_level.to_f / 6)
    filtered = number_to_percentage(filtered*100)
    # maybe refactor later, to acccount for change of English-flag-circular.png to British-flag-circular.png
    language_or_nationality = message.sender.language
    language_or_nationality = 'British' if language_or_nationality == 'English'
    # language_or_nationality = 'Chinese' if language_or_nationality == 'Mandarin Chinese'
    if language_or_nationality.in?(['Python', 'Ruby On Rails', 'Javascript'])
      image_tag("computer-flags/#{language_or_nationality}-logo.png", :style => "-webkit-filter: grayscale(#{filtered});", alt: "#{message.sender.language}")
    else
      image_tag("country-flags/#{language_or_nationality}-flag-circular.png", :style => "-webkit-filter: grayscale(#{filtered});", alt: "#{message.sender.language}")
    end
  end

end
