# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  email                 :string           not null
#  name                  :string           default("New User"), not null
#  age                   :integer          default(25), not null
#  language              :string           default("Spanish"), not null
#  language_level        :integer          default(3), not null
#  password_digest       :string           not null
#  session_token         :string           not null
#  image                 :string
#  active                :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  title                 :string           default("Please fill in your profession"), not null
#  provider              :string
#  uid                   :string
#  location              :string
#  latitude              :float
#  longitude             :float
#  nationality           :string           default("Spanish"), not null
#  matches_token         :string
#  matches_sent_at       :datetime
#  braintree_customer_id :string
#  person_of_interest    :boolean          default(FALSE), not null
#  tutor                 :boolean          default(FALSE), not null
#  interests             :text
#  activation_token      :string
#  activated             :boolean          default(FALSE)
#  ip_address            :string
#  birthdate             :date
#

class User < ApplicationRecord
  # maybe refactor, anytime change user's active status searchkick is reindexed, which I don't think is necessary
  searchkick callbacks: :async, text_start: [:name, :language_and_level, :location]
  # maybe refactor and add filter to only search activated accounts (precautionary)
  scope :search_import, -> { includes(:linkedin, :materials) }
  # maybe add this (for all autocomplete fields), not sure if it helps: scope :name_like, -> (name) { where("name ilike ?", name) }
  acts_as_tagger
  include Locatable
  # not sure if it's a good idea to have helpers in model files, maybe move methods into concern file or application_controller.rb#helper_method
  include UsersHelper
  # need to update _translate.html.erb, users_helper.rb#user_convert_to_language(nationality), #user_convert_to_nationalities(language), users/index.html.erb, routes.rb, and seeds.rb any time there is a change
  LANGUAGES = ["English", "Spanish", "Italian", "German", "French", "Mandarin Chinese", "Danish"]
  # need to update users_helper.rb#user_convert_to_presented_language_level(language_level) any time there is a change
  LANGUAGE_LEVELS = (1..6).to_a
  # maybe refactor, maybe need to change some ish to ian for language vs. nationality mix up, add other country names like 'Holland' to keys
  NATIONALITIES = {
    "Algeria" => "Algerian",
    "Armenia" => "Armenian",
    "Argentina" => "Argentinian",
    "Australia" => "Australian",
    "Austria" => "Austrian",
    "Azerbaijan" => "Azerbaijani",
    "Bangladesh" => "Bengali",
    "Belgium" => "Belgian",
    "Bolivia" => "Bolivian",
    "Brazil" => "Brazilian",
    "Bulgaria" => "Bulgarian",
    "Cambodia" => "Cambodian",
    "Canada" => "Canadian",
    "Chile" => "Chilean",
    "China" => "Chinese",
    "Colombia" => "Colombian",
    "Costa Rica" => "Costarican",
    "Croatia" => "Croatian",
    "Cyprus" => "Cypriot",
    "Czech Republic" => "Czech",
    "Czechoslovakia" => "Czechoslovakian",
    "Denmark" => "Danish",
    "Ecuador" => "Ecuadorian",
    "Egypt" => "Egyptian",
    "El Salvador" => "El Salvadorian",
    "Estonia" => "Estonian",
    "Ethiopia" => "Ethiopian",
    "Finland" => "Finnish",
    "France" => "French",
    "Georgia" => "Georgian",
    "Germany" => "German",
    "Guatemala" => "Guatemalan",
    "Greece" => "Greek",
    "Honduras" => "Honduran",
    "Hungary" => "Hungarian",
    "Iceland" => "Icelandic",
    "India" => "Indian",
    "Indonesia" => "Indonesian",
    "Iran" => "Iranian",
    "Iraq" => "Iraqi",
    "Ireland" => "Irish",
    "Israel" => "Israeli",
    "Italy" => "Italian",
    "Japan" => "Japanese",
    "Jamaica" => "Jamaican",
    "Jordan" => "Jordanian",
    "Kazakhstan" => "Kazakhstani",
    "Kenya" => "Kenyan",
    "Latvia" => "Latvian",
    "Lebanon" => "Lebanese",
    "Libya" => "Libyan",
    "Lithuania" => "Lithuanian",
    "Luxembourg" => "Luxembourgish",
    "Malaysia" => "Malaysian",
    "Malta" => "Maltan",
    "Mexico" => "Mexican",
    "Morocco" => "Moroccan",
    "Netherlands" => "Dutch",
    "New Zealand" => "New Zealander",
    "Nicaragua" => "Nicaraguan",
    "Nigeria" => "Nigerian",
    "Norway" => "Norwegian",
    "Oman" => "Omanian",
    "Panama" => "Panamanian",
    "Paraguay" => "Paraguayan",
    "Peru" => "Peruvian",
    "Philippines" => "Philippino",
    "Poland" => "Polish",
    "Portugal" => "Portuguese",
    "Romania" => "Romanian",
    "Russia" => "Russian",
    "Qatar" => "Qatari",
    "Saudi Arabia" => "Saudi Arabian",
    "Singapore" => "Singaporean",
    "Serbia" => "Serbian",
    "Slovakia" => "Slovakian",
    "Slovenia" => "Slovenian",
    "South Africa" => "South African",
    "South Korea" => "South Korean",
    "Spain" => "Spanish",
    "Sweden" => "Swedish",
    "Syria" => "Syrian",
    "Thailand" => "Thai",
    "Turkey" => "Turkish",
    "Ukraine" => "Ukrainian",
    "United Arab Emirates" => "Emirati",
    "United Kingdom" => "British",
    "Uruguay" => "Uruguayan",
    "U.S.A" => "American",
    "Venezuela" => "Venezuelan",
    "Vietnam" => "Vietnamese"
  }

  attr_reader :password, :terms

  mount_uploader :image, AvatarUploader
  geocoded_by :location
  serialize :interests, Array

  after_initialize :ensure_session_token

  # Maybe refactor: get rid of :downcase_email (and all calls to downcase email throughout) or make :downcase_email and titleize_name before_save so emails and names are case insensitive, makes sense for these to be before_validation now since records can be found and added in database without conflict
  # maybe refactor, need if present since these are before_validation, really only a problem when creating an invalid user object from the command line
  before_validation :downcase_email, if: -> { email.present? && email_changed? }
  before_validation :titleize_name, if: -> { name.present? && name_changed? }
  before_validation :calculate_age, if: -> { birthdate.present? } # calculating age everytime user is updated since age should be updated everytime user performs action on platform

  # maybe refactor and take out :session_token so only fields that user can input
  validates_presence_of :email, :name, :age, :language, :language_level, :password_digest, :session_token, :title, :nationality
  validates_presence_of :birthdate, on: :create
  validates :email, uniqueness: true, length: {maximum: 255}, format: {:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/i, on: :create}
  # maybe refactor lowercase \z instead of \Z like above
  validates :name, uniqueness: true, length: {minimum: 2, maximum: 255}, format: {:with => /\A[^.]*\Z/i, message: "No period allowed"}
  validates :password, length: { minimum: 5, maximum: 50, allow_nil: true }
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 18, less_than_or_equal_to: 120 }
  validates_inclusion_of :language, in: LANGUAGES
  validates_inclusion_of :language_level, in: LANGUAGE_LEVELS
  validates :image, file_size: { less_than_or_equal_to: 5.megabytes }
  validates :title, length: {minimum: 5, maximum: 255}
  # for now only have Linkedin, in the future may add Github, Facebook, etc.
  validates_inclusion_of :provider, in: ["linkedin"], allow_nil: true
  # Add Linkedin to message since only using Linkedin as partner right now
  validates :uid, uniqueness: { scope: :provider, allow_nil: true, message: "Linkedin account already registered with another user" }
  validates_inclusion_of :nationality, in: NATIONALITIES.values
  # maybe refactor and add latitude and longitude validations (that they're floats)
  # to prevent nil values in boolean field, according to stackoverflow
  validates_inclusion_of :active, :person_of_interest, :tutor, :activated, in: [true, false]
  validates :interests, length: {maximum: 10, message: "Only 10 interests allowed"}
  validates :terms, acceptance: true

  after_validation :geocode, if: :location_present_and_changed?
  # for case of just wanting to delete location
  after_validation :remove_location, if: :location_not_present_and_changed?
  after_validation :error_and_remove_location, if: [:location_present_and_changed?, :latitude_unchanged?]

  before_create :generate_activation_token

  after_create :add_email_subscription
  after_create :add_standard_package

  # keeping this for the dependent: :destroy aspect
  has_many :initiated_chat_rooms, :foreign_key => :initiator_id, class_name: 'ChatRoom', dependent: :destroy
  has_many :received_chat_rooms, :foreign_key => :recipient_id, class_name: 'ChatRoom', dependent: :destroy
  # maybe refactor, dependent: :delete_all redundant here, if all of user's chat_rooms are destroyed, all sent_messages should already be destroyed, messages can only belong to chat_rooms at the moment, if message can belong to other objects or there are chat_rooms with more than 2 people change :delete_all to :destroy
  has_many :sent_messages, :foreign_key => :sender_id, class_name: 'Message', dependent: :delete_all
  has_many :posts, :foreign_key => :owner_id, class_name: 'Post', dependent: :destroy
  has_many :comments, :foreign_key => :owner_id, class_name: 'Comment', dependent: :destroy
  has_many :votes, :foreign_key => :owner_id, class_name: 'Vote', dependent: :destroy
  has_many :follows, :foreign_key => :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :followed_posts, through: :follows, source: :followable, source_type: 'Post'
  has_many :notifications, -> { where read: false}, :foreign_key => :notified_id, dependent: :destroy
  # maybe refactor and get rid of read_notifications, mainly used for destroying notifications not covered in above
  has_many :read_notifications, -> {where read: true}, :foreign_key => :notified_id, class_name: 'Notification', dependent: :destroy
  has_many :created_notifications, :foreign_key => :notifier_id, class_name: 'Notification', dependent: :destroy
  # No dependent: :destroy here since covered in above
  has_many :posts_notifications, -> { where read: false, notifiable_type: 'Post'}, :foreign_key => :notified_id, class_name: 'Notification'
  has_many :chat_rooms_notifications, -> { where read: false, notifiable_type: 'ChatRoom'}, :foreign_key => :notified_id, class_name: 'Notification'
  has_one :linkedin, dependent: :destroy
  # in the future, if add more objects that user can read (besides Board), should add an association like :reads_of_boards, -> {where readable_type: 'Board'}
  has_many :reads, dependent: :destroy
  has_many :read_boards, through: :reads, source: :readable, source_type: 'Board'
  # for now can only purchase one package, may change this to feature add-ons to purchases
  has_one :purchase, :foreign_key => :buyer_id, dependent: :destroy
  has_one :package, through: :purchase
  has_one :email_subscription, dependent: :destroy
  # maybe refactor and remove dependent: :destroy for :reviews in case user returns to the platform
  has_many :reviews, as: :reviewable, dependent: :destroy
  # keep created reviews even if user is deleted
  has_many :created_reviews, :foreign_key => :reviewer_id, class_name: 'Review'
  # maybe refactor and keep materials (if materials are property of smartxchange) after user is deleted, however issue of validating owner
  has_many :materials, :foreign_key => :owner_id, class_name: 'Material', dependent: :destroy

  default_scope -> { order(created_at: :asc) } # maybe refactor take this out, asc want oldest users around first

  def to_param
    name.downcase
  end

  def self.find_by_param(input)
    find_by_name(input.split("%20").join(" ").titleize)
  end

  def self.find_by_credentials(user_params)
    user = User.find_by_email(user_params[:email].downcase)
    if user && user.try(:is_password?, user_params[:password])
      return user
    elsif user
      return user.email
    else
      return nil
    end
  end

  def self.new_token
    SecureRandom.urlsafe_base64(16)
  end

  def self.create_with_omniauth(auth)
    # ensures email uniqueness validation through if statement in previous previous method
    # will set password as uid, hack job need to refactor
    # maybe refactor, hack fix for if user doesn't have a Linkedin image, name defaults to 'New User' if there is a uniqueness error
    image = auth['extra']['raw_info']['pictureUrls'].values.second ? auth['extra']['raw_info']['pictureUrls'].values.second[0] : nil
    # No !'s here, add_, and update_ with_omniauth because want the user to be saved even if there are validation errors, which is why we have save_valid_attributes!
    # Default birthdate to 25 years ago
    user = User.create(
      email: auth['info']['email'],
      password: auth['uid'],
      name: auth['info']['name'],
      title: auth['info']['description'],
      remote_image_url: image,
      provider: auth['provider'],
      uid: auth['uid'],
      location: auth['info']['location']['name'],
      birthdate: 25.years.ago
    )
    # may implement positions, specialties and more once these start working
    Linkedin.create(
      user_id: user.id,
      public_url: auth['info']['urls'].public_profile,
      industry: auth['extra']['raw_info']['industry'],
      summary: auth['extra']['raw_info']['summary']
    )
    # maybe refactor here, add_with_omniauth!, and update_with_omniauth!, quick fix for when adding with Linkedin and location not valid, still want other values to persist
    user.save_valid_attributes!
    user
  end

  def add_with_omniauth!(auth)
    # doesn't need error messages because fields can be blank (except Linkedin user_id which should not throw error unless there is no current_user in which case there would be an error earlier on)
    self.update(
      provider: auth['provider'],
      uid: auth['uid'],
      location: auth['info']['location']['name']
    )
    Linkedin.create(
      user_id: self.id,
      public_url: auth['info']['urls'].public_profile,
      industry: auth['extra']['raw_info']['industry'],
      summary: auth['extra']['raw_info']['summary']
    )
    self.save_valid_attributes!
  end

  def update_with_omniauth!(auth)
    # doesn't need error messages because fields can be blank
    # keeping provider and uid there because maybe the person has a new linkedin account
    # not updating password if uid changes because user might have sign in without linkedin
    self.update(
      provider: auth['provider'],
      uid: auth['uid'],
      location: auth['info']['location']['name']
    )
    self.linkedin.update(
      public_url: auth['info']['urls'].public_profile,
      industry: auth['extra']['raw_info']['industry'],
      summary: auth['extra']['raw_info']['summary']
    )
    self.save_valid_attributes!
  end

  def delete_omniauth!
    self.linkedin.destroy
    self.update(
      provider: nil,
      uid: nil
    )
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def reset_token!
    self.session_token = User.new_token
    self.save! # keep exclamation mark here since want it to fail if it doesn't save, this is an important call
    self.session_token
  end

  def appear!
    p "appear called in user"
    if !self.active
      self.active = true
      self.save
    end
  end

  def disappear!
    p "disappear called in user"
    if self.active
      self.active = false
      self.save
    end
  end

  def sort_method
    User.where(language: self.language).where.not(id: self.id).includes(:linkedin).sort {|u1, u2| u2.sort_value(self) <=> u1.sort_value(self) }
  end

  # maybe make #user_convert_to_language and #user_convert_to_nationalities User methods so don't have to include users_helper.rb
  def sort_exchange
    language = user_convert_to_language(self.nationality)
    nationalities = user_convert_to_nationalities(self.language)
    User.where("nationality IN (:nationalities)", nationalities: nationalities).where(language: language).where.not(id: self.id).includes(:linkedin).sort {|u1, u2| u2.sort_value(self) <=> u1.sort_value(self) }
  end

  def sort_value(base_user)
    denominator = self.language_level > base_user.language_level ? (self.language_level.to_f * 2) : (base_user.language_level.to_f * 2)
    sort = (self.language_level.to_f + base_user.language_level.to_f) / denominator
    # using latitude in case there was a failed geocode on location, precaution but better this way
    sort *= 1.5 if base_user.latitude && self.latitude && base_user.distance_from(self) < 50
    sort *= 1.5 if base_user.age > self.age - 10 && base_user.age < self.age + 10
    base_user.interests.each {|interest| sort *= 1.1 if self.interests.include?(interest)}
    sort
  end

  def create_matches_token!
    self.matches_token = User.new_token
    self.matches_sent_at = Time.zone.now
    self.save! # bang here because don't want #language_matches email to send if matches_token is not saved
    self.matches_token
  end

  def subscribe_to_premium
    # assuming can only subscribe to the premium package (2nd package) for now, for this and premium?  method
    self.package = Package.second
  end

  def unsubscribe_to_premium
    self.package = Package.first
  end

  def has_braintree_info?
    self.braintree_customer_id
  end

  def chat_bot?
    self.id == 6
  end

  def premium?
    self.package == Package.second
  end

  # maybe add admin column if there are many admins in the future
  def admin?
    self.id == 1 || self.id == 340 || self.id == 224
  end

  def premium_or_admin?
    self.premium? || self.admin?
  end

  # have to make unprotected so works when creating a user in User.create_with_omniauth
  def save_valid_attributes!
    # probably refactor, hack to get user to save to database and save errors as notices
    notices = errors.full_messages.to_sentence
    restore_attributes(errors.keys) unless valid?
    save
    notices
  end

  def boards_notifications
    boards_notifications = Hash.new
    self.posts_notifications.includes(:notifiable).each do |post_notification|
      # bug, pretty sure it's resolved, no longer need check for next unless post_notification.read == false, used to be an issue with Boards() post notifications being 1 higher than sum of dropdown boards post notifications
      board_id = post_notification.notifiable.board_id
      boards_notifications[board_id] ? boards_notifications[board_id] << post_notification : boards_notifications[board_id] = [post_notification]
    end
    boards_notifications
  end

  def boards_notifications_count
    boards_notifications_count = Hash.new
    boards_notifications.each do |board_id, board_notifications|
      boards_notifications_count[board_id] = board_notifications.count
    end
    boards_notifications_count
  end

  def search_data
    # ignoring case, refactor, maybe add more categories (like post) in this way: on_sale: sale_price.present?, reindex with rake searchkick:reindex:User
    # only after_commit reindexing on material since every time user's linkedin is updated that user is also updated (add_with_omniauth!, update_with_omniauth!, ...)
    {
      name: name,
      age: age.to_s,
      # No space between practicing and language, hack that returns better results (only those users who are actually practicing that language - don't know why it works better but it does) - works better except if language has a space like 'Mandarin Chinese' which becomes 'practicingMandarin Chinese' in search_data
      language: "practicing" + language,
      language_and_level: language + " " + user_convert_to_presented_language_level(language_level),
      active: active? ? "active" : nil,
      title: title,
      location: location,
      nationality: "native" + nationality,
      person_of_interest: person_of_interest? ? "person of interest" : nil,
      tutor: tutor? ? "tutor" : nil,
      interests: interests.any? ? user_convert_to_interests(interests) : nil,
      chat_bot: chat_bot? ? "chat bot" : nil,
      # maybe refactor linkedin, rather have one check for linkedin.present? even if it's eager loaded, if someone has a Linkedin should always have industry and summary so ( || ) is just precautionary
      linkedin_industry_and_summary: linkedin.present? ? (linkedin.industry || "") + " " + (linkedin.summary || "") : nil,
      material_language_and_level: materials.any? ? materials.map {|material| material.language + " " + user_convert_to_presented_language_level(material.language_level) + " materials" } : nil
    }
  end

  protected

  def ensure_session_token
    self.session_token ||= User.new_token
  end

  def downcase_email
    self.email = self.email.downcase
  end

  def titleize_name
    self.name = self.name.downcase.titleize
  end

  def calculate_age
    self.age = ((Date.today - self.birthdate)/365).to_i
  end

  def add_email_subscription
    EmailSubscription.create!(user_id: self.id) # exclamation mark here, don't want to have a user created without associated email subscription object
  end

  def add_standard_package
    self.package = Package.first
  end

  def generate_activation_token
    self.activation_token = User.new_token
  end

end
