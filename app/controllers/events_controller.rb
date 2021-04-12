class EventsController < ApplicationController
  include EventsHelper
  include MembersHelper
  before_action :active_staff_only, except: [:serve_file]
  before_action :find_selected_event, only: [
    :show, :edit, :update, :destroy,
    :change_role, :switch_black_list_flg, :update_birthday, :change_status,
    :destroy_relationship,
    :update_registed_member, :update_participants,
    :registed, :participants, :dotasan, :declined, :dotacan, :no_show,
    :waiting, :search_member,
    :account,
    :serve_file
  ]

  def index
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
    if params[:year].present?
      year = Date.parse(params[:year])
      base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    else
      #base = Event.where(:start_time => @start_date..@last_date).group(:start_time)
      base = Event.where(:start_time => @last_date.beginning_of_year...@last_date.end_of_year).group(:start_time)
    end
    @events = base.order("start_time DESC")

    array = Member.where(:gtic_flg => nil).pluck(:id)
    @total_events = Event.count
    @total_participants = Relationship.where(member_id: array).where(status: 3).count
    @participants = Relationship.where(member_id: array).where(status: 3).group(:member_id).pluck(:member_id).count
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to event_path(@event)
    else
      render 'new'
    end
  end

  def show
    @presentations = @event.presentations.order("created_at desc")
    @fb_event = facebook_objects(@event.fb_event_id)
  end

  def edit
    @title = "イベント情報編集"
    @participants = @event.participants.paginate(page:params[:page]).order("last_name_alphabet")
  end

  def update
    if @event.update(event_params)
      redirect_to event_path(@event), :flash => {:success => '変更しました'}
    else
      render 'edit'
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path
  end

  def search
    @events = get_search_event(params[:keyword])
    respond_to :js
  end

  def upload_file
    event = Event.find(params[:id])
    file = params[:file]
    if file
      if params[:header] == 'header'
        event.update(header_data: file.read, header_filename: file.original_filename, header_mime_type: file.content_type)
      else
        event.update(bkg_data: file.read, bkg_filename: file.original_filename, bkg_mime_type: file.content_type)
      end
    end
    redirect_to event_path(event)
  end

  def serve_file
    @event = Event.find(params[:id])
    if params[:header] == 'header'
      send_data(@event.header_data, :type => @event.header_mime_type, :filename => "@{@event.header_filename}", :disposition => "inline")
    else
      send_data(@event.bkg_data, :type => @event.bkg_mime_type, :filename => "@{@event.bkg_filename}", :disposition => "inline")
    end
  end

  def check_in
    if not params[:id] or not Event.find(params[:id])
      redirect_to root_path, notice: "ERROR! Not validate 'event' id."
      return
    end
    event = Event.find(params[:id])

    # Get member
    if not params[:member_id]
      redirect_to event_path(event), notice: "ERROR! No member_id_hash."
      return
    end
    member_id = verify_string_from_hash(params[:member_id])
    member = Member.find(member_id)
    if not member
      redirect_to event_path(event), notice: "ERROR! Not validate member_id_hash."
      return
    end

    # Find registered member
    relationship = event.relationships.find_by_member_id(member.id)
    if relationship.blank?
      redirect_to event_path(event), notice: "ERROR! Not registerd yet."
    else
      if relationship.status == 3
        redirect_to participants_event_path(event), flash: { notice: "WARNING! Already Checked in: " + member.last_name + member.first_name }
      else
        relationship.update(status: 3) # registered --> participated
        redirect_to participants_event_path(event), flash: { success: "SUCCESS! Checked in: " + member.last_name + member.first_name }
      end
    end
  end

  # =================================================
  # Member status list pages
  def registed
    @members = @event.registed_members.sort_by_role_alphabet
    @referer = "registed"
    respond_to do |format|
      format.html
      format.xls {send_data render_to_string(partial: "member_download"),  filename: "resisted.xls"}
      format.js
    end
  end

  def update_registed_member
    @title = "#{@event.name} 参加予定者情報編集"
    @members = @event.registed_members.order("last_name_alphabet")
    respond_to :js
  end

  def participants
    @members = @event.participants.sort_by_role_alphabet
    @referer = "participants"
    respond_to do |format|
      format.html
      format.xls {send_data render_to_string(partial: "member_download"),  filename: "participants.xls"}
      format.js
    end
  end

  def update_participants
    @title = "#{@event.name} 出席者情報編集"
    @members = @event.participants.order("last_name_alphabet")
    respond_to :js
  end

  def dotasan
    @members = @event.dotasan.sort_by_role_alphabet
    @referer = "dotasan"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def declined
    @members = @event.declined_members.sort_by_role_alphabet
    @referer = "declined"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def dotacan
    @members = @event.dotacan.sort_by_role_alphabet
    @referer = "dotacan"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def no_show
    @members = @event.no_show.sort_by_role_alphabet
    @referer = "no_show"
    respond_to do |format|
      format.html
      format.js
    end
  end

  # Search member
  def waiting # Get for member
    @recorded = Member.recorded_member(@event)
    @members = Member.limit(50)
    @not_found_members = []
    @referer = "waiting"
    respond_to do |format|
      format.js
      format.json { render :json => @members.select(:id, :last_name, :name) }
    end
  end

  def search_member
    @recorded = Member.recorded_member(@event)
    @members = get_search_member(params[:keyword])
    respond_to :js
  end


  # =================================================
  # Member actions
  def change_status
    relationship = @event.relationships.find_by_member_id(params[:member_id])
    direction = params[:direction].to_i
    if relationship.blank?
      relationship = Relationship.new(member_id: params[:member_id], event_id: params[:id], status: 2).save
    else
      case direction
      when 0
        relationship.update(status: 0)
      when 2
        relationship.update(status: 2)
      when 3
        relationship.update(status: 3)
      when 4
        relationship.update(status: 4)
      when 5
        relationship.update(status: 5)
      when 6
        relationship.update(status: 6)
      when 7
        relationship.update(status: 7)
      end
    end
    select_action(params[:referer])
  end

  def change_role
    relationship = @event.relationships.find_by_member_id(params[:member_id])
    member = Member.find_by_id(params[:member_id])
    case params[:role]
    when "gtic"
      relationship.update(presentation_role: -1)
    when "participant"
      relationship.update(presentation_role: 0)
      member.update(past_presenter_flg: false)
    when "presenter"
      relationship.update(presentation_role: 1)
      member.update(past_presenter_flg: true)
    when "panelist"
      relationship.update(presentation_role: 2)
      member.update(past_presenter_flg: true)
    when "moderator"
      relationship.update(presentation_role: 3)
      member.update(past_presenter_flg: true)
    when "guest"
      relationship.update(presentation_role: 4)
      member.update(past_presenter_flg: false)
    when "past_presenter"
      relationship.update(presentation_role: 5)
      member.update(past_presenter_flg: true)
    end
    select_action(params[:referer])
  end

  def destroy_relationship
    relationship = @event.relationships.find_by_member_id(params[:member_id])
    if relationship.present?
      relationship.destroy
    end
    redirect_to registed_event_path(@event)
  end

  def switch_black_list_flg
    member = Member.find(params[:member_id])
    flg = member.black_list_flg == true ? false : true
    member.update(black_list_flg: flg)
    select_action(params[:referer])
  end

  def update_birthday
    member = Member.find(params[:member_id])
    birthday = params[:birthday] ? @event.start_time.beginning_of_month : nil
    member.update(birthday: birthday)
    select_action(params[:referer])
  end


  # =================================================
  def statistics
    @title = "統計"
    if params[:id].present?
      @event = Event.find(params[:id])
      record = @event.participants.group(:category_id).count
      @category = record.map{|key,val| [key.present? ? Category.find(key).name : "未登録", val]}
      membership = @event.relationships.where("status = 2 or status = 3")
      @date_count = membership.group("date(created_at)").count.map{|key,val| [key,val]}
    else
      @events = Event.all
      # Events stat
      @event_names = @events.map{|event| '<a href="'+event_path(event)+'">'+event.name+'</a>' }
      @participants = @events.map{|event| event.participants.count}
      @declined = @events.map{|event| event.declined_members.count}
      @dotasan = @events.map{|event| event.dotasan.count}
      @dotacan = @events.map{|event| event.dotacan.count}
      @no_show = @events.map{|event| event.no_show.count}
    end
  end

  def account
    @title = "会計"
    range = @event.start_time.beginning_of_month..@event.start_time.end_of_month
    fee = @event.fee || 0
    participants = @event.participants
    participant = participants.pluck(:id)
    presenter = @event.relationships.where(status: 3).where(presentation_role: 1).pluck(:member_id)
    guest = @event.relationships.where(status: 3).where(guest_flg: true).pluck(:member_id)
    gtic = participants.where(gtic_flg: true).pluck(:id)
    free = (presenter + guest + gtic).uniq
    student = participants.where(category_id: 10).pluck(:id) - free
    birthday = participants.where(birthday: range).pluck(:id) - free

    if @event.registers.blank?
      Register.create( event_id: @event.id, account_id: 1, amount: participant.count * fee )
      Register.create( event_id: @event.id, account_id: 2, amount: gtic.count * fee )
      Register.create( event_id: @event.id, account_id: 3, amount: presenter.count * fee )
      Register.create( event_id: @event.id, account_id: 4, amount: guest.count * fee )
      Register.create( event_id: @event.id, account_id: 5, amount: student.count * 1000 )
      Register.create( event_id: @event.id, account_id: 6, amount: birthday.count * 1000 )
    end
    @registers_pos = @event.registers.joins(:account).where("accounts.positive =?", true)
    @registers_neg = @event.registers.joins(:account).where("accounts.positive =?", false)
  end

  def download
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
    if params[:year].present?
      year = Date.parse(params[:year])
      base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    else
      base = Event.where(:start_time => @start_date..@last_date).group(:start_time)
    end
    record = base.order("start_time DESC")
    @events = get_formated_events(record)

    array = Member.where(:gtic_flg => nil).pluck(:id)
    @total_events = Event.count
    @total_participants = Relationship.where(member_id: array).where(status: 3).count
    @participants = Relationship.where(member_id: array).where(status: 3).group(:member_id).pluck(:member_id).count

    respond_to do |format|
      format.html
      format.xls {send_data render_to_string(partial: "event_download"),  filename: "events.xls"}
      format.js
    end
  end


  private
    def event_params
      params.require(:event).permit(
          :name, :cumulative_number,
          :start_time, :end_time,
          :fb_event_id, :place_id,
          :fee, :event_category_id, :note
      )
    end

    def find_selected_event
      if params[:id].present?
        @event = Event.find(params[:id])
      elsif params[:event_id].present?
        @event = Event.find(params[:event_id])
      end
    end

    def select_action(referer)
      case referer
      when "registed"
        registed
      when "participants"
        participants
      when "dotasan"
        dotasan
      when "declined"
        declined
      when "dotacan"
        dotacan
      when "no_show"
        no_show
      when "waiting"
        redirect_to waiting_event_path, turbolinks: false # off turbolinks for ajax
      end
    end
end
