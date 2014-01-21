class StaticPagesController < ApplicationController
  def home
    if signed_in?
      redirect_to members_path
    end
 
  end
end
