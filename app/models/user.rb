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
  # maybe refactor and take away (searchkick callbacks: :async)
  searchkick callbacks: :async
  # maybe refactor and add filter to only search activated accounts (precautionary)
  scope :search_import, -> { includes(:linkedin, :materials) }
  include Locatable
  include UsersHelper
  # need to update _translate.html.erb, users_helper.rb#user_convert_to_language(nationality), #user_convert_to_nationalities(language) any time there is a change
  LANGUAGES = ["English", "Spanish", "Italian", "German", "French", "Mandarin Chinese"]
  # need to update users_helper.rb#user_convert_to_scripted_language_level(language_level), #user_convert_to_language_level(scripted_language_level), #user_convert_to_presented_language_level(language_level) any time there is a change
  LANGUAGE_LEVELS = (1..6).to_a

  attr_reader :password, :terms

  mount_uploader :image, AvatarUploader
  geocoded_by :location
  serialize :interests, Array

  after_initialize :ensure_session_token

  # Maybe refactor: get rid of :downcase_email (and all calls to downcase email throughout) or make :downcase_email and titleize_name before_save so emails and names are case insensitive, makes sense for these to be before_validation now since records can be found and added in database without conflict
  # maybe refactor, need if present since these are before_validation, really only a problem when creating an invalid user object from the command line
  before_validation :downcase_email, if: 'email.present?'
  before_validation :titleize_name, if: 'name.present?'
  before_validation :calculate_age, if: 'birthdate.present?' # calculating age everytime user is updated since age should be updated everytime user performs action on platform

  # maybe refactor and take out :session_token so only fields that user can input
  validates_presence_of :email, :name, :age, :language, :language_level, :password_digest, :session_token, :title, :nationality
  validates_presence_of :birthdate, on: :create
  validates :email, uniqueness: true, length: {maximum: 255}, format: {:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/i, on: :create}
  validates :password, length: { minimum: 5, maximum: 50, allow_nil: true }
  validates :title, length: {minimum: 5, maximum: 255}
  validates :name, uniqueness: true, length: {minimum: 2, maximum: 255}, format: {:with => /\A[^.]*\Z/i, message: "No period allowed"}
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 18 }
  validates_inclusion_of :language, in: LANGUAGES
  validates_inclusion_of :language_level, in: LANGUAGE_LEVELS
  # to prevent nil values in boolean field, according to stackoverflow
  validates :person_of_interest, :tutor, :inclusion => {:in => [true, false]}
  validates :interests, length: {maximum: 10, message: "Only 10 interests allowed"}
  # Add Linkedin to message since only using Linkedin as partner right now
  validates :uid, uniqueness: { scope: :provider, allow_nil: true, message: "Linkedin account already registered with another user" }
  # for now only have Linkedin, in the future may add Github, Facebook, etc.
  validates_inclusion_of :provider, in: ["linkedin"], allow_nil: true
  validates :image, file_size: { less_than_or_equal_to: 5.megabytes }
  validates :terms, acceptance: true

  after_validation :geocode, if: :location_present_and_changed?
  after_validation :remove_location, if: :location_not_present_and_changed?
  after_validation :error_and_remove_location, if: :location_present_and_changed_and_latitude_unchanged?

  before_create :generate_activation_token
  after_create :add_email_subscription

  has_many :notifications, -> { where read: false}, :foreign_key => :notified_id, dependent: :destroy
  has_many :read_notifications, -> {where read: true}, :foreign_key => :notified_id, class_name: 'Notification', dependent: :destroy
  has_many :created_notifications, :foreign_key => :notifier_id, class_name: 'Notification', dependent: :destroy
  # No dependent: :destroy here since covered in above
  has_many :posts_notifications, -> { where read: false, notifiable_type: 'Post'}, :foreign_key => :notified_id, class_name: 'Notification'
  has_many :chat_rooms_notifications, -> { where read: false, notifiable_type: 'ChatRoom'}, :foreign_key => :notified_id, class_name: 'Notification'
  # keeping this for the dependent: :destroy aspect
  has_many :initiated_chat_rooms, :foreign_key => :initiator_id, class_name: 'ChatRoom', dependent: :destroy
  has_many :received_chat_rooms, :foreign_key => :recipient_id, class_name: 'ChatRoom', dependent: :destroy
  has_many :sent_messages, :foreign_key => :sender_id, class_name: 'Message', dependent: :destroy
  has_one :linkedin, dependent: :destroy
  has_many :posts, :foreign_key => :owner_id, class_name: 'Post', dependent: :destroy
  has_many :comments, :foreign_key => :owner_id, class_name: 'Comment', dependent: :destroy
  has_many :votes, :foreign_key => :owner_id, class_name: 'Vote', dependent: :destroy
  has_many :follows, :foreign_key => :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :followed_posts, through: :follows, source: :followable, source_type: 'Post'
  has_many :reads, dependent: :destroy
  has_many :read_boards, through: :reads, source: :readable, source_type: 'Board'
  # for now can only purchase one package, may change this to feature add-ons to purchases
  has_one :purchase, :foreign_key => :buyer_id, dependent: :destroy
  has_one :package, through: :purchase
  has_one :email_subscription, dependent: :destroy
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_many :created_reviews, :foreign_key => :reviewer_id, class_name: 'Review', dependent: :destroy
  has_many :materials, :foreign_key => :owner_id, class_name: 'Material', dependent: :destroy

  default_scope -> { order(created_at: :asc) } #may refactor take this out, asc want oldest users around first

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
    self.active = true
    self.save
  end

  def disappear!
    p "disappear called in user"
    self.active = false
    self.save
  end

  def sort_method
    User.where(language: self.language).where.not(id: self.id).includes(:linkedin).sort {|u1, u2| u2.sort_value(self) <=> u1.sort_value(self) }
  end

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

  def search_data
    # ignoring case, refactor, maybe add more categories (like post) in this way: on_sale: sale_price.present?, reindex with rake searchkick:reindex:User
    # only after_commit reindexing on material since every time user's linkedin is updated that user is also updated (add_with_omniauth!, update_with_omniauth!, ...)
    {
      name: name,
      age: age.to_s,
      language: language,
      language_level: user_convert_to_scripted_language_level(language_level),
      active: active? ? "active" : nil,
      title: title,
      location: location,
      nationality: nationality,
      person_of_interest: person_of_interest? ? "person of interest" : nil,
      tutor: tutor? ? "tutor" : nil,
      interests: interests.any? ? user_convert_to_interests(interests).to_sentence : nil,
      chat_bot: chat_bot? ? "chat bot" : nil,
      linkedin_industry: linkedin.present? ? linkedin.industry : nil,
      linkedin_summary: linkedin.present? ? linkedin.summary : nil,
      materials: materials.any? ? "materials" : nil
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

  def generate_activation_token
    self.activation_token = User.new_token
  end

end
