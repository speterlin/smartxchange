# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class AppearanceChannel < ApplicationCable::Channel
  # may need to refactor these try calls and replace with something, but at the moment if a user isn't logged in there is an error

  def subscribed
    current_user
  end

  # maybe refactor this, unsure of its use
  def unsubscribed
    current_user.try(:disappear!)
  end

  # took out (data)
  def appear
    current_user.try(:appear!)
    # on: data['appearing_on']
  end

  def disappear
    current_user.try(:disappear!)
  end
end
