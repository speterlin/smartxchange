class StaticPagesController < ApplicationController

  skip_before_action :require_signed_in

  def about
  end

  def contact
  end
  
end
