class StaticPagesController < ApplicationController
  def home
    if signed_in?
      redirect_to members_path
    end
  end

  def about
  end

  def presenter
    @presenters = Event.all.map{|event| [event.name, event.presenters.map{|presenter| [[presenter.last_name, presenter.first_name].join(" "), presenter.affiliation]}]} 
  end

  def organizer
  end
end
