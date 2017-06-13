module UsersHelper

  # probably need to refactor the below 3 methods, this method has a bug - counting twice if there's a match
  def user_count_unread_board_notifications(user, board)
    count = 0
    user.posts_notifications.each do |post_notification|
      # refactor, hack job for now have to add where read == false since association is lagging
      count += 1 if post_notification.notifiable.board_id == board.id && post_notification.read == false
    end
    count
  end

  def user_first_unread_board_notification(user, board)
    user.posts_notifications.each do |post_notification|
      return post_notification if post_notification.notifiable.board_id == board.id
    end
  end

  def user_boards_notifications_with_title(user)
    boards_notifications = Hash.new
    Board.all.each do |board|
      # maybe refactor get rid of board title, need for web notifications channel displaying in header
      boards_notifications[board.id] = [board.title, user_count_unread_board_notifications(user, board)]
    end
    boards_notifications
  end

  def user_has_unread_materials?(user)
    return true if user.updated_at < Material.last.updated_at
    false
  end

  def user_convert_language_level(rating)
    if rating == 1
      return "A1 - beginner"
    elsif rating == 2
      return "A2 - elementary"
    elsif rating == 3
      return "B1 - intermediate"
    elsif rating == 4
      return "B2 - upper intermediate"
    elsif rating == 5
      return "C1 - advanced"
    elsif rating == 6
      return "C2 - master"
    end
  end

  def user_convert_language_level_to_rating(level)
    # assuming level always comes in as lower case
    if level == "a1"
      return 1
    elsif level == "a2"
      return 2
    elsif level == "b1"
      return 3
    elsif level == "b2"
      return 4
    elsif level == "c1"
      return 5
    elsif level == "c2"
      return 6
    end
  end

  def user_convert_language_or_nationality_to_img(nationality)
    image_tag("country-flags/#{nationality}-flag-circular.png", alt: "#{nationality}")
  end

  def user_convert_nationality_to_language(nationality)
    language = nationality
    language = 'English' if user_convert_language_to_nationalities('English').include?(nationality)
    language = 'Spanish' if user_convert_language_to_nationalities('Spanish').include?(nationality)
    language = 'German' if user_convert_language_to_nationalities('German').include?(nationality)
    language = 'Mandarin Chinese' if user_convert_language_to_nationalities('Mandarin Chinese').include?(nationality)
    language
  end

  def user_convert_language_to_nationalities(language)
    if language == 'English'
      return ['Australian', 'British', 'Canadian', 'Irish', 'Jamaican', 'New Zealander', 'South African', 'USA']
    elsif language == 'Spanish'
      return ['Argentinian', 'Bolivian', 'Chilean', 'Colombian', 'Costarican', 'Ecuadorian', 'El Salvadorian', 'Guatemalan', 'Honduran', 'Mexican', 'Nicaraguan', 'Panamanian', 'Peruvian', 'Spanish', 'Uruguayan', 'Venezuelan']
    elsif language == 'German'
      return ['Austrian', 'German']
    elsif language == 'Mandarin Chinese'
      return ['Chinese']
    else
      return [language]
    end
  end

  def user_nationalities
    # maybe refactor and make object, maybe need to change some ish to ian for language vs. nationality mix up
    [
      ["Algerian", "Algeria"],
      ["Armenian", "Armenia"],
      ["Argentinian", "Argentina"],
      ["Australian", "Australia"],
      ["Austrian", "Austria"],
      ["Azerbaijani", "Azerbaijan"],
      ["Bengali", "Bangladesh"],
      ["Belgian", "Belgium"],
      ["Bolivian", "Bolivia"],
      ["Brazilian", "Brazil"],
      ["Bulgarian", "Bulgaria"],
      ["Cambodian", "Cambodia"],
      ["Canadian", "Canada"],
      ["Chilean", "Chile"],
      ["Chinese", "China"],
      ["Colombian", "Colombia"],
      ["Costarican", "Costa Rica"],
      ["Croatian", "Croatia"],
      ["Cypriot", "Cyprus"],
      ["Czech", "Czech Republic"],
      ["Czechoslovakian", "Czechoslovakia"],
      ["Danish", "Denmark"],
      ["Dutch", "Netherlands"],
      ["Ecuadorian", "Ecuador"],
      ["Egyptian", "Egypt"],
      ["El Salvadorian", "El Salvador"],
      ["Estonian", "Estonia"],
      ["Ethiopian", "Ethiopia"],
      ["Filipino", "Philippines"],
      ["Finnish", "Finland"],
      ["French", "France"],
      ["Georgian", "Georgia"],
      ["German", "Germany"],
      ["Guatemalan", "Guatemala"],
      ["Greek", "Greece"],
      ["Honduran", "Honduras"],
      ["Hungarian", "Hungary"],
      ["Icelandic", "Iceland"],
      ["Indian", "India"],
      ["Indonesian", "Indonesia"],
      ["Iranian", "Iran"],
      ["Iraqi", "Iraq"],
      ["Irish", "Ireland"],
      ["Israeli", "Israel"],
      ["Italian", "Italy"],
      ["Japanese", "Japan"],
      ["Jamaican", "Jamaica"],
      ["Jordanian", "Jordan"],
      ["Kazakhstani", "Kazakhstan"],
      ["Kenyan", "Kenya"],
      ["Latvian", "Latvia"],
      ["Lebanese", "Lebanon"],
      ["Libyan", "Libya"],
      ["Lithuanian", "Lithuania"],
      ["Luxembourgish", "Luxembourg"],
      ["Malaysian", "Malaysia"],
      ["Maltan", "Malta"],
      ["Mexican", "Mexico"],
      ["Moroccan", "Morocco"],
      ["New Zealander", "New Zealand"],
      ["Nicaraguan", "Nicaragua"],
      ["Nigerian", "Nigeria"],
      ["Norwegian", "Norway"],
      ["Omanian", "Oman"],
      ["Panamanian", "Panama"],
      ["Paraguayan", "Paraguay"],
      ["Peruvian", "Peru"],
      ["Philippino", "Philippines"],
      ["Polish", "Poland"],
      ["Portuguese", "Portugal"],
      ["Romanian", "Romania"],
      ["Russian", "Russia"],
      ["Qatari", "Qatar"],
      ["Saudi Arabian", "Saudi Arabia"],
      ["Singaporean", "Singapore"],
      ["Serbian", "Serbia"],
      ["Slovakian", "Slovakia"],
      ["Slovenian", "Slovenia"],
      ["South African", "South Africa"],
      ["South Korean", "South Korea"],
      ["Spanish", "Spain"],
      ["Swedish", "Sweden"],
      ["Syrian", "Syria"],
      ["Thai", "Thailand"],
      ["Turkish", "Turkey"],
      ["Ukrainian", "Ukraine"],
      ["Emirati", "United Arab Emirates"],
      ["British", "United Kingdom"],
      ["Uruguayan", "Uruguay"],
      ["USA", "U.S.A"],
      ["Venezuelan", "Venezuela"],
      ["Vietnamese", "Vietnam"]
    ]
  end

  def user_convert_interests(number)
    if number == 1
      return "Sales / Business Development"
    elsif number == 2
      return "Marketing"
    elsif number == 3
      return "Engineering"
    elsif number == 4
      return "Web Development / Design"
    elsif number == 5
      return "Finance"
    elsif number == 6
      return "Law"
    elsif number == 7
      return "Project Management"
    elsif number == 8
      return "Research"
    elsif number == 9
      return "Consulting"
    elsif number == 10
      return "Medicine"
    elsif number == 11
      return "Start-ups"
    elsif number == 12
      return "Financial Services"
    elsif number == 13
      return "Pharma"
    elsif number == 14
      return "Architecture"
    elsif number == 15
      return "Computer Software"
    elsif number == 16
      return "Education"
    elsif number == 17
      return "Fashion"
    elsif number == 18
      return "Literature"
    elsif number == 19
      return "Music"
    elsif number == 20
      return "Art"
    elsif number == 21
      return "Futbol / Soccer"
    elsif number == 22
      return "Basketball"
    elsif number == 23
      return "Rugby"
    elsif number == 24
      return "American Football"
    elsif number == 25
      return "Padel"
    elsif number == 26
      return "Table Tennis"
    elsif number == 27
      return "Tennis"
    elsif number == 28
      return "Running"
    elsif number == 29
      return "Biking"
    elsif number == 30
      return "Hiking"
    end
  end

  # may refactor, this logic is something that should be in application helper, but don't want to have to include ApplicationHelper in UsersHelper and in scheduler.rake
  def user_days_from_beginning_of_year
    (Date.today - Date.parse("1/1/2017")).to_i
  end

  # num indicates day of the week, counts up to 6, 0 is Sunday, 1 is Monday ... 6 is Saturday. Jan 1,  2017 was a Sunday, this is why 0 = Sunday. Number is offset by 1, i.e. Jan 30 would be 29 days from beginning of year
  def user_weekly_beginning_and_end(num)
    number = User.count / 7
    multiple = (user_days_from_beginning_of_year % 7 + num) % 7
    beginning_number = multiple * number
    ending_number = multiple == 6 ? User.count : beginning_number + number
    User.all[beginning_number...ending_number]
  end

end
