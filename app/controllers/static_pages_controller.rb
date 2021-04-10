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

  def event_list
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
  end

  def search_event
    @events = get_search_event(params[:keyword])
    respond_to :js
  end

  def event_detail
    if not params[:event_id]
      redirect_to root_path, notice: "Not validate url."
      return
    end
    @event = Event.find(params[:event_id])

    @is_expired_event =  is_expired_event(@event.start_time)

    @presentations = @event.presentations.order("created_at desc")
    if current_user
      @relationship = @event.relationships.find_by_member_id(current_user.member_id)
    end
  end

  def register_event
    if not params[:event_id]
      redirect_to root_path, notice: "Not validate url."
      return
    end
    event = Event.find(params[:event_id])

    # Check time
    if is_expired_event(event.start_time)
      redirect_to event_detail_path(event_id: event.id), notice: "今は参加登録できません。GTICスタッフに直接連絡お願いします。Cannot register now. Please contact to GTIC staff directry."
      return
    end

    # Get member id
    if current_user
      user = User.find(current_user.id)
      member = user.member
      member_id = member.id
    else
      member = Member.from_registration(params)
      member_id = member.id
    end
    # Find if member already registered
    relationship = event.relationships.find_by_member_id(member_id)
    # If member not regitered
    if relationship
      if relationship == 2
        redirect_to event_detail_path(event_id: event.id), flash: { notice: "Already registered!" }
      else
        relationship.update(status: 2)
        redirect_to event_detail_path(event_id: event.id), flash: { success: "Successfully registered!" }
      end
    else
      Relationship.new(member_id: member_id, event_id: event.id, status: 2).save
      # Send mail
      NoReplyMailer.registration_confirmation(event, member).deliver
      redirect_to event_detail_path(event_id: event.id), flash: { success: "Successfully registered!" }
    end
  end

  def deregister_event
    if not params[:event_id]
      redirect_to root_path, notice: "Not validate url."
      return
    end
    event = Event.find(params[:event_id])

    # Check time
    if is_expired_event(event.start_time)
      redirect_to root_path, notice: "今はキャンセルできません。GTICスタッフに直接連絡お願いします。Cannot deregister now. Please contact to GTIC staff directry."
      return
    end

    if current_user
      user = User.find(current_user.id)
      member = user.member
      member_id = member.id
    else
      if not params[:member_id]
        redirect_to root_path, notice: "Not validate url."
        return
      end

      member_id = verify_string_from_hash(params[:member_id])
      member = Member.find(id: member_id)
      if not member
        redirect_to root_path, notice: "Not validate url."
        return
      end
      member_id = member.id
    end

    # Find member already registered
    relationship = event.relationships.find_by_member_id(member_id)
    if relationship.blank?
      redirect_to root_path, notice: "Not registerd yet."
    else
      relationship.update(status: 4)
      # Send mail
      NoReplyMailer.deregistration_confirmation(event, member).deliver
      redirect_to event_detail_path(event_id: event.id), notice: "参加登録をキャンセルしました。Successfully deregistered the event."
    end
  end

  def organizer
    @access_token = get_app_access_token
    @organizers = Staff.all
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

  private
    def is_expired_event(start_time)
      return DateTime.now > start_time-60*60*7 # Before 7h before start
    end


end
