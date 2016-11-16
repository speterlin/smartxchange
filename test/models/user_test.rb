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
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
  end

  test "Users set by fixtures" do
    assert_equal(4, User.count)
  end

  test "test chat_bot? method" do
    assert_equal(false, User.first.chat_bot?)
  end

  test "test sort_method" do
    assert_equal(3, User.first.sort_method[0..2].count)
  end

end
