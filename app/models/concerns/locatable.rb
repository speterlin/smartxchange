module Locatable
  extend ActiveSupport::Concern

  def location_present_and_changed?
    return true if (self.location.present? && self.location_changed?)
    false
  end

  def location_not_present_and_changed?
    return true if (!self.location.present? && self.location_changed?)
    false
  end

  def remove_location
    self.location = nil
    self.longitude = nil
    self.latitude = nil
  end

  def error_unless_latitude_changed
    self.errors.add(:location, "is not valid") unless self.latitude_changed?
  end

end
