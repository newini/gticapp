class EventsController < ApplicationController
  include EventsHelper
  include MembersHelper
  before_action :signed_in_user
  before_action :selected_event,
    only: [:show, :edit, :update, :destroy, :switch_presenter_flg,:switch_guest_flg, :switch_black_list_flg, :update_member,
           :invited, :waiting, :registed, :participants, :canceled, :no_show, :change_status,
           :change_all_waiting_status, :send_invitation, :send_email, :update_facebook, :new_member, :search]
  def index
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
    year = params[:year].present? ? Date.parse(params[:year]) : @last_date 
    base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    record = base.order("start_time DESC")
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
    array = Member.where(:gtic_flg => nil).pluck(:id)
    @total_events = Event.count
    @total_participants = Relationship.where(member_id: array).where(status: 2..3).count
    respond_to do |format|
      format.html
      format.js
    end
  end
  def show
    @participants = @event.participants
    @presentations = @event.presentations
    @presentation = Presentation.new
    @presenters = @event.presenters
    @presenters_ary = @presenters.map{|presenter| [[presenter.last_name, presenter.first_name].join(" "), presenter.id]}
    @registed_members = @event.registed_members
    @graph = facebook_objects(@event.fb_event_id)
    @fb_event_info = @graph[@event.fb_event_id] if @graph.present?
  end

  def edit
    @title = "イベント情報編集"
    @participants = @event.participants.paginate(page:params[:page]).order("last_name_kana")
  end

  def update
    if @event.update_attributes(event_params)
      redirect_to event_path, :flash => {:success => '変更しました'}
    else
      render 'edit'
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save 
#      @new_members = Member.where.not(:id => @event.relationships.select(:member_id).map(&:member_id))
#      if @new_members.present?
#        @new_members.each do |new_member|
#          @event.relationships.create(member_id: new_member.id, event_id: @event.id, status: 1)
#      end
#    end

      redirect_to events_path
    else
      render 'new'
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path
  end
  
  def import
    Event.import(params[:file])
    redirect_to events_path, :flash => {:success => "インポートされました" }
  end
  def import_registed_members
    Event.import_registed_members(params[:file],params[:id]) 
    redirect_to event_path, :flash => {:success => "インポートされました"}
  end


  def import_participants
    Event.import_participants(params[:file],params[:id]) 
    redirect_to event_path, :flash => {:success => "インポートされました"}
  end

  def switch_presenter_flg
    @relationship = @event.relationships.find_by_member_id(params[:member_id])
    if params[:switch] == "on"
      @relationship.update(presenter_flg: true, guest_flg: false)
    elsif params[:switch] == "off"
      @relationship.update(presenter_flg: false, guest_flg: false)
    end
    if @relationship.save!
      redirect_to :back
    end
  end

  def switch_guest_flg
    @relationship = @event.relationships.find_by_member_id(params[:member_id])
    if params[:switch] == "on"
      @relationship.update(guest_flg: true, presenter_flg: false)
    elsif params[:switch] == "off"
      @relationship.update(guest_flg: false, presenter_flg: false)
    end
    if @relationship.save!
      redirect_to :back
    end
  end

  def switch_black_list_flg
    @member = Member.find(params[:member_id])
    flg = @member.black_list_flg == true ? false : true
    redirect_to no_show_event_path, :flash => {:success => "更新しました"} if @member.update(black_list_flg: flg)
  end

  def invited 
    #@members = @event.invited_members.paginate(page:params[:page]).order("last_name_kana")
    @title = "#{@event.name} 招待済みメンバー"
    @members = @event.invited_members.order("last_name_kana")
  end

  def waiting
    @title = "#{@event.name} 参加予定者追加"
    @members = waiting_members.order("last_name_kana").limit(100)
    respond_to do |format|
      format.html
      format.js
      format.json { render :json => @members.select(:id, :last_name, :fb_name) }
    end
  end

  def registed
    @title = "#{@event.name} 参加予定者"
    @members = @event.registed_members.order("last_name_kana")
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def participants
    @title = "#{@event.name} 出席者"
    @members = @event.participants.order("last_name_kana")
  end

  def canceled
    @title = "#{@event.name} キャンセルしたメンバー"
    @members = @event.canceled_members.order("last_name_kana")
  end

  def no_show
    @title = "#{@event.name} No-show"
    @members = @event.no_show.order("last_name_kana")
  end

  def change_status
    @members = @event.members.order("last_name_kana")
    @relationship = @event.relationships.find_by_member_id(params[:member_id])
    @direction = params[:direction].to_i
    if @relationship.nil?
      @relationship = Relationship.new(member_id: params[:member_id], event_id: params[:id], status: 2)
    elsif @relationship.status == 0
      @relationship.update(status: 2)
    elsif @relationship.status >= 1
      case @direction
      when 0
        @relationship.update(status: 0)
      when 2
        @relationship.update(status: 2)
      when 3
        @relationship.update(status: 3)
      when 4 
        @relationship.update(status: 4)
      when 5 
        @relationship.update(status: 5)
      end
    end
    if @relationship.save
      redirect_to :back, :flash => {:success => "更新しました"}
    end
  end
  def change_all_waiting_status
    @members = @event.waiting_members.where(black_list_flg: false).where("email IS NOT NULL").order("last_name_kana")
    @members.each do |member|
      relationship = @event.relationships.find_by_member_id(member.id)
      if relationship.status == 0
        relationship.update(status: 1)
      end
      relationship.save
    end
    redirect_to :back, :flash => {:success => "更新しました"}
  end

  def send_invitation
    @invitations = Invitation.where(event_id: params[:event_id])
  end
  def send_email
    @send_flg = params[:send_flg].to_i
    if @send_flg== 1
      @members = @event.invited_members
      @members.each do |member|
        InvitationMailer.invitation(member,@event,params[:invitation_id]).deliver
        flash[:success] = "メール送信完了！"
      end
    end
    redirect_to send_invitation_path(@event)
  end
  def update_facebook
    @rsvp_status = params[:rsvp_status]
    @fb_members = facebook(@event.fb_event_id, @rsvp_status)
    @fb_members.each do |fb_member|
      fb_name = fb_member["name"]
      fb_user_id = fb_member["id"]
      if Member.find_by_fb_user_id(fb_user_id).present?
        @member = Member.find_by_fb_user_id(fb_member["id"])
        @member.update(fb_name: fb_name, fb_user_id: fb_user_id)
      else
        @member = Member.new(fb_name: fb_name, fb_user_id: fb_user_id)
      end
      @member.save!
      if @member.relationships.find_by_event_id(@event.id).blank?
        @relationship = @member.relationships.new(event_id: @event.id, status: convert_status(@rsvp_status))
        @relationship.save!
      elsif @member.relationships.find_by_event_id(@event.id).status < 2
        @relationship = @member.relationships.find_by_event_id(@event.id)
        @relationship.update(event_id: @event.id, status: convert_status(@rsvp_status))
        @relationship.save!
      end
    end
    redirect_to :back
  end

  def search
    @title = "#{@event.name} 参加予定者追加"
    if params[:search].present? 
      @members = waiting_members.where("last_name like ?", "%#{params[:search]}%").order("last_name_kana")
    else
      @members = waiting_members.order("last_name_kana")
    end
    respond_to do |format|
      format.js
    end
  end

  def update_presentation
    params[:presentation].each do |presentation|
      record = Presentation.where(member_id: presentation[:member_id]).find_by_event_id(presentation[:event_id]) || Presentation.new(member_id: presentation[:member_id], event_id: presentation[:event_id])
      record.update(title: presentation[:title], abstract: presentation[:abstract])
      record.save!
    end
    redirect_to :back
  end

  def update_member
    @title = "#{@event.name} 参加予定者情報編集"
    @members = @event.registed_members.order("last_name_kana")
    respond_to do |format|
      format.js
    end
  end

  def convert
    @presentations = Presentation.all
    @presentations.each do |presentation|
      event_id = presentation.event_id
      member_id = presentation.member_id
      presentation_id = presentation.id
      presentationship = Presentationship.where(event_id: event_id).find_by_member_id(member_id) || Presentationship.new(event_id: event_id, member_id: member_id)
      presentationship.update(presentation_id: presentation_id)
      presentationship.save
    end
    redirect_to events_path
  end

   
  private
    def event_params
      params.require(:event).permit(:name, :start_time, :end_time, :fb_event_id, :place_id, :fee)
    end
    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end
    def selected_event
      @event = Event.find(params[:id])
    end

end
