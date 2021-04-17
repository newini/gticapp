class StaticPagesController < ApplicationController
  # reCAPTCHA
  prepend_before_action :check_captcha, only: [:register_event]


  def home
    # Get new events
    @events = Event.where('start_time > ?', DateTime.now).order("start_time DESC")

    # Get one media article
    @media_articles = MediaArticle.where('date > ?', DateTime.now - 30*3).order(date: :DESC) # now - days
  end

  def about
    @events = Event.all.order("start_time DESC")
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
    @events = base.order("start_time DESC")
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

    @is_expired_event =  isExpiredEvent(@event.start_time)

    @presentations = @event.presentations.order("created_at desc")
    if current_user
      @relationship = @event.relationships.find_by_member_id(current_user.member_id)
    end

    @member = member_params ? Member.new(member_params) : Member.new
  end

  def register_event
    validateEventId(params[:event_id])
    event = Event.find(params[:event_id])

    # Check time
    if isExpiredEvent(event.start_time)
      redirect_to event_detail_path(event_id: event.id), notice: "今は参加登録できません。GTICスタッフに直接連絡お願いします。Cannot register now. Please contact to GTIC staff directry."
      return
    end

    # Get member
    if current_user
      user = User.find(current_user.id)
      member = user.member
      if not member
        redirect_to edit_user_path(user), flash: { notice: "ユーザー情報をご記入ください。Please fill your information." }
        return
      end
    else
      member = Member.from_registration(member_params)
    end

    # Find if member already registered
    relationship = event.relationships.find_by_member_id(member.id)
    # If member not regitered
    if relationship
      relationship.update(status: 2)
    else
      Relationship.new(member_id: member.id, event_id: event.id, status: 2).save
    end

    # Send register confirm mail
    NoReplyMailer.registration_confirmation(event, member).deliver
    redirect_to view_registration_path(event_id: event.id, member_id: generate_hash_from_string(member.id)), flash: { success: "Successfully registered!" }
  end

  def deregister_event
    validateEventId(params[:event_id])
    event = Event.find(params[:event_id])

    # Check time
    if isExpiredEvent(event.start_time)
      redirect_to root_path, notice: "今はキャンセルできません。GTICスタッフに直接連絡お願いします。Cannot deregister now. Please contact to GTIC staff directry."
      return
    end

    # get member
    if current_user
      user = User.find(current_user.id)
      member = user.member
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
    end

    # Find member already registered
    relationship = event.relationships.find_by_member_id(member.id)
    if relationship.blank?
      redirect_to root_path, notice: "Not registerd yet."
    else
      relationship.update(status: 4)
      # Send cancel confirm mail
      NoReplyMailer.deregistration_confirmation(event, member).deliver
      redirect_to event_detail_path(event_id: event.id), notice: "参加登録をキャンセルしました。Successfully deregistered the event."
    end
  end

  def view_registration
    validateEventId(params[:event_id])
    @events = Event.where(id: params[:event_id]) # get array for convenience
    event = @events.first

    # Check time
    if isExpiredEvent(event.start_time, 6)
      redirect_to root_path, notice: "このURLは有効でありません。Cannot request with this URL."
      return
    end

    # get member
    if current_user
      user = User.find(current_user.id)
      member = user.member
      member_id_hash = generate_hash_from_string(member.id)
    else
      if not params[:member_id]
        redirect_to root_path, notice: "Not validate url."
        return
      end
      member_id_hash = params[:member_id]
      member_id = verify_string_from_hash(member_id_hash)
      member = Member.find(member_id)
      if not member
        redirect_to root_path, notice: "Not validate url."
        return
      end
    end

    # Check registered
    relationship = event.relationships.find_by_member_id(member.id)
    if not relationship or relationship.status == 4
      #render file: "#{Rails.root}/public/404.html", layout: false, status: 404
      redirect_to root_path, notice: "このURLは有効でありません。Cannot request with this URL."
      return
    end

    # Generate QR code
    require 'rqrcode'
    qrcode = RQRCode::QRCode.new( "https://gtic.jp"+check_in_event_path(id: params[:event_id], member_id: member_id_hash) )
    @qrcode_svg = qrcode.as_svg(module_size: 6)
  end

  def organizer
    @access_token = get_app_access_token
    @organizers = Staff.all
  end

  def media
    @media_articles = MediaArticle.paginate(page: params[:page], per_page: 9).order(date: :desc)
  end

  def contact_us
    @contact = contact_params ? Contact.new(contact_params) : @contact = Contact.new

    if params[:after_submit]
      @after_submit = true
    end
  end


  private
    def contact_params
      params.fetch(:contact, {}).permit(
        :name, :category_id, :affiliation, :title, :email,
        :subject, :body
      )
    end

    def member_params
      params.fetch(:member, {}).permit(
        :first_name, :last_name, :first_name_alphabet, :last_name_alphabet,
        :category_id, :affiliation, :title, :email
      )
    end


    def isExpiredEvent(start_time, hour=-7)
      return DateTime.now > start_time+60*60*hour # Default 7h before start
    end

    def validateEventId(event_id)
      if not event_id or not Event.find(event_id)
        redirect_to root_path, notice: "Not validate url."
        return
      end
    end

    # reCAPTCHA
    def check_captcha
      unless verify_recaptcha
        redirect_to event_detail_path(event_id: params[:event_id], member: member_params, anchor: 'registration')
      end
    end


end
