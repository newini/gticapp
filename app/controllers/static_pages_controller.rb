class StaticPagesController < ApplicationController
  def home
    if signed_in?
      redirect_to events_path
    end
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
    base = Event.where(:start_time => @start_date..@last_date).group(:start_time)
    record = base.order("start_time DESC")
    @events = record.map{
      |event| [
        event: {
          id: event.id, 
          name: event.name, 
          date: event.start_time.strftime("%Y-%m-%d"), 
          place: event.place_id, 
          event_category_id: event.event_category_id
        }, 
        detail: event.presentations.search_presentation(params[:keyword]).map{
          |presentation| [
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.search_presenter(params[:bio]).map{
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

  def about
  end

  def presenter
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
#    year = params[:year].present? ? Date.parse(params[:year]) : @last_date 
#    if params[:year].present?
#      year = Date.parse(params[:year])
#      base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
#    else
    base = Event.where(:start_time => @start_date..@last_date).group(:start_time)
#    end 
    record = base.order("start_time DESC")
    @events = record.map{
      |event| [
        event: {
          id: event.id, 
          name: event.name, 
          date: event.start_time.strftime("%Y-%m-%d"), 
          place: event.place_id, 
          event_category_id: event.event_category_id
        }, 
        detail: event.presentations.search_presentation(params[:keyword]).map{
          |presentation| [
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.search_presenter(params[:bio]).map{
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
    respond_to do |format|
      format.html
      format.js
    end
  end

  def organizer
  end

  def schedule
  end

  def media_introduce
  end

  def contact
  end
  



end
