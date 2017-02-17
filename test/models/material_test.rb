# == Schema Information
#
# Table name: materials
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  attachment :string           not null
#  owner_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class MaterialTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
