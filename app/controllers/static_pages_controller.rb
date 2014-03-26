class StaticPagesController < ApplicationController
  def home
    if signed_in?
      redirect_to members_path
    end
  end

  def about
  end

  def presenter
    record = Event.all.order("start_time DESC")
    @events = record.map{|event| [event: {name: event.name, date: event.start_time.strftime("%Y-%m-%d") }, detail: event.presenters.map{|presenter| [name: [presenter.last_name, presenter.first_name].join(" "), affiliation: presenter.affiliation, title: presenter.title, presentation_title: presenter.presentations.find_by_event_id(event.id).try(:title)]}.flatten]}.flatten
  end

  def organizer
  end
end
