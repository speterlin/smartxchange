module Locatable
  extend ActiveSupport::Concern

  def location_present_and_changed
    return true if (self.location.present? && self.location_changed?)
    # needs to be refactored
    if self.location == "" && self.location_changed?
      self.location = nil
      self.longitude = nil
      self.latitude = nil
    end
    return false
  end

  def lat_changed?
    # for some reason need to return at the end
    if self.location_changed? && self.location != ""
        if !self.latitude_changed?
            self.errors.add(:location, "is not valid")
            return false
        end
    end
    return true
  end

end
