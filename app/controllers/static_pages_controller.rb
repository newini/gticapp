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
    @events = record.map{
      |event| [
        event: {
          id: event.id, 
          name: event.name, 
          date: event.start_time.strftime("%Y-%m-%d"), 
          place: event.place_id 
        }, 
        detail: event.presentations.map{
          |presentation| [
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.map{
              |presenter| [
                name: [presenter.last_name, presenter.first_name].join(" "), 
                affiliation: presenter.affiliation, 
                title: presenter.title
              ]
            }.flatten
          ]
        }.flatten
      ]
    }.flatten

  end

  def organizer
  end
end
