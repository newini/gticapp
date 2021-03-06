class StaticPagesController < ApplicationController

  def home
    # Get events
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
        detail: event.presentations.map{
          |presentation| [
            id: presentation.id,
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.order('id asc').map{
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

    # Get one media article
    @media_article = MediaArticle.all.order(date: :DESC)[0]
  end

  def about
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
        detail: event.presentations.map{
          |presentation| [
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.order('id asc').map{
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
          cumulative_number: event.cumulative_number,
          date: event.start_time.strftime("%Y-%m-%d"),
          place: event.place_id,
          event_category_id: event.event_category_id
        },
        detail: event.presentations.map{
          |presentation| [
            id: presentation.id,
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.order('id asc').map{
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
  end # End of presenter

  def search_event
    record = Event.group(:start_time).order("start_time DESC")
    events_count = record.count
    # Search algorithm
    if params[:keyword].present?
      record = []
      Event.all.order("start_time DESC").each do |event|
        if event.presentations.search_presentation(params[:keyword]).present? # Search in presentation
          record.push(event)
        end
        event.presentations.each do |presentation|
          if presentation.presenters.search_presenter(params[:keyword]).present? # search in presenter's member
            if !record.include? event # check duplicate
              record.push(event)
            end
          end
        end
      end
    end
    @events = record.map{
      |event| [
        event: {
          id: event.id,
          name: event.name,
          cumulative_number: event.cumulative_number,
          date: event.start_time.strftime("%Y-%m-%d"),
          place: event.place_id,
          participants: event.participants.count,
          event_category_id: event.event_category_id
        },
        detail: event.presentations.map{
          |presentation| [
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.order('id asc').map{
              |presenter| [
                name: [presenter.last_name, presenter.first_name].join(" "),
                affiliation: presenter.affiliation,
                title: presenter.title,
              ]
            }.flatten
          ]
        }.flatten
      ]
    }.flatten
    respond_to :js
  end # End of search_event


  def organizer
    @access_token = get_app_access_token
    @organizers = Staff.all
  end

  def schedule
  end

  def media
    @media_articles = MediaArticle.all.order(date: :desc)
  end

  def contact
  end

end
