class MessagesController < ApplicationController
  def create
    redirect_back fallback_location: root_path, alert: "Please enable JavaScript to send messages."
  end
end
