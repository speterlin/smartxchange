module UsersHelper

  def user_has_unread_materials?(user)
    return true if user.updated_at < Material.last.updated_at
    false
  end

  def user_related_material(user)
    related_material = Material.where(language: user.language).where.not(owner_id: user.id).where('language_level >= ? AND language_level <= ?',(user.language_level - 1), (user.language_level + 1)).order(updated_at: :desc).limit(10)
    related_material
  end

  def user_convert_to_presented_language_level(language_level)
    # in case wrongly passed a language_level outside of User::LANGUAGE_LEVELS
    return false unless language_level.in?(User::LANGUAGE_LEVELS)
    if language_level == 1
      return "A1 - beginner"
    elsif language_level == 2
      return "A2 - elementary"
    elsif language_level == 3
      return "B1 - intermediate"
    elsif language_level == 4
      return "B2 - upper intermediate"
    elsif language_level == 5
      return "C1 - advanced"
    elsif language_level == 6
      return "C2 - master"
    end
  end

  def user_convert_language_or_nationality_to_img(language_or_nationality)
    if language_or_nationality.in?(['Python', 'Ruby On Rails', 'Javascript'])
      image_tag("computer-flags/#{language_or_nationality}-logo.png", alt: "#{language_or_nationality}")
    else
      image_tag("country-flags/#{language_or_nationality}-flag-circular.png", alt: "#{language_or_nationality}")
    end
  end

  def user_convert_to_language(nationality)
    # here and in user_convert_to_nationalities, check simple nationalities first
    if nationality.in?(['Italian', 'French', 'Danish'])
      return nationality
    elsif user_convert_to_nationalities('English').include?(nationality)
      return 'English'
    elsif user_convert_to_nationalities('Spanish').include?(nationality)
      return 'Spanish'
    elsif user_convert_to_nationalities('German').include?(nationality)
      return 'German'
    elsif user_convert_to_nationalities('Mandarin Chinese').include?(nationality)
      return 'Mandarin Chinese'
    end
  end

  def user_convert_to_nationalities(language)
    if language.in?(['Italian', 'French', 'Danish'])
      return [language]
    elsif language == 'English'
      return ['Australian', 'British', 'Canadian', 'Irish', 'Jamaican', 'New Zealander', 'South African', 'American']
    elsif language == 'Spanish'
      return ['Argentinian', 'Bolivian', 'Chilean', 'Colombian', 'Costarican', 'Ecuadorian', 'El Salvadorian', 'Guatemalan', 'Honduran', 'Mexican', 'Nicaraguan', 'Panamanian', 'Peruvian', 'Spanish', 'Uruguayan', 'Venezuelan']
    elsif language == 'German'
      return ['Austrian', 'German']
    elsif language == 'Mandarin Chinese'
      return ['Chinese']
    end
  end

  def user_convert_to_interest(number)
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

  def user_convert_to_interests(interest_nums)
    user_interests = []
    interest_nums.each do |interest_num|
      user_interests << user_convert_to_interest(interest_num)
    end
    user_interests
  end

  # maybe refactor, this logic is something that should be in application helper, but don't want to have to include ApplicationHelper in UsersHelper and in scheduler.rake
  def user_days_from_beginning_of_year
    (Date.today - Date.parse("1/1/#{Date.today.year}")).to_i
  end

  # group_num indicates day of the week, counts up to 6, for 2017: 0 is Sunday, 1 is Monday ... 6 is Saturday. Jan 1,  2017 was a Sunday, this is why 0 = Sunday. Number is offset by 1, i.e. Jan 30 would be 29 days from beginning of year
  def users_group_by_day_of_week_and_group_num(group_num)
    users_in_each_group = User.count / 7
    current_day_of_week = user_days_from_beginning_of_year % 7
    # + group_num % 7 so it starts over at 0 after get above 6
    current_group_num = (current_day_of_week + group_num) % 7
    start_index = current_group_num * users_in_each_group
    end_index = current_group_num == 6 ? User.count : start_index + users_in_each_group
    User.all[start_index...end_index]
  end

end
