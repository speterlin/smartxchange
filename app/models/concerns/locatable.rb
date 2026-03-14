module Locatable
  extend ActiveSupport::Concern

  def location_present_and_changed?
    location.present? && will_save_change_to_location? # here and below - chatgpt says location_changed? and latitude_changed? are deprecated in rails 7.2 # return true if (self.location.present? && self.location_changed?) # false
  end

  def location_not_present_and_changed?
    location.blank? && will_save_change_to_location? # return true if (!self.location.present? && self.location_changed?) # false
  end

  def latitude_unchanged?
    !will_save_change_to_latitude? # return true if !self.latitude_changed? # false
  end

  # maybe refactor and remove remove_location, self.errors presents self from being saved
  def error_and_remove_location
    self.errors.add(:location, "is not valid")
    remove_location
  end

  def remove_location
    self.location = nil
    self.longitude = nil
    self.latitude = nil
  end

end
