# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  classification :string           not null
#  description    :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  price          :decimal(8, 2)
#

class Package < ApplicationRecord
  validates_presence_of :classification, :description
  # maybe refactor not sure about dependent destroy here
  has_many :purchases, dependent: :destroy
  has_many :buyers, through: :purchases

  def uncapitalize_description
    # refactor maybe put in application controller
    self.description[0, 1].downcase + self.description[1..-1]
  end

end
