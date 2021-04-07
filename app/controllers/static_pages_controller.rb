class StaticPagesController < ApplicationController

  def home
    # Get events
    record = Event.where('start_time < ?', DateTime.now-24*60*60).group(:start_time).order("start_time DESC")
    @events = get_formated_events(record)

    # Get one media article
    @media_article = MediaArticle.where('date > ?', DateTime.now-31*24*60*60).order(date: :DESC)[0]
  end

  def about
    record = Event.all.group(:start_time).order("start_time DESC")
    @events = get_formated_events(record)
  end

  def presenter
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
    if params[:year].present?
      year = Date.parse(params[:year])
      base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    else
      base = Event.where(:start_time => @last_date.beginning_of_year...@last_date.end_of_year).group(:start_time)
    end
    record = base.order("start_time DESC")
    @events = get_formated_events(record)
  end # End of presenter

  def search_event
    @events = get_search_event(params[:keyword])
    respond_to :js
  end

  def organizer
    @access_token = get_app_access_token
    @organizers = Staff.all
  end

  def schedule
  end

  def media
    @media_articles = MediaArticle.paginate(page: params[:page], per_page: 10).order(date: :desc)
  end

  def contact_us
    @contact = Contact.new
    if params[:after_submit]
      @after_submit = true
    end
  end

end
