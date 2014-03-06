class EventsController < ApplicationController
  include EventsHelper
  include MembersHelper
  before_action :signed_in_user
  before_action :selected_event, only: [:show, :edit, :update, :destroy, :switch_presenter_flg,:switch_guest_flg, :switch_black_list_flg,
                                        :invited, :waiting, :registed, :participants, :canceled, :no_show, :change_status,
                                        :change_all_waiting_status, :send_invitation, :send_email, :update_facebook]
  def index
    @events = Event.paginate(page: params[:page]).order("start_time DESC")
    array = Member.where(:gtic_flg => nil).pluck(:id)
    @total_events = Event.count
    @total_participants = Relationship.where(member_id: array).where(status: 2..3).count
  end
  def show
    @participants = @event.participants
    @presenters = @event.presenters
    @invited_members = @event.invited_members
    @registed_members = @event.registed_members
  end

  def edit
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
      @new_members = Member.where.not(:id => @event.relationships.select(:member_id).map(&:member_id))
      if @new_members.present?
        @new_members.each do |new_member|
          @event.relationships.create(member_id: new_member.id, event_id: @event.id, status: 0)
      end
    end

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
    @members = @event.invited_members.order("last_name_kana")
  end

  def waiting
    @members = @event.waiting_members.where(black_list_flg: false).where("email IS NOT NULL").order("last_name_kana")
  end

  def registed
    @members = @event.registed_members.order("last_name_kana")
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def participants
    @members = @event.participants.order("last_name_kana")
  end

  def canceled
    @members = @event.canceled_members.order("last_name_kana")
  end

  def no_show
    @members = @event.no_show.order("last_name_kana")
  end

  def change_status
    @members = @event.members.order("last_name_kana")
    @relationship = @event.relationships.find_by_member_id(params[:member_id])
    @direction = params[:direction].to_i
    if @relationship.nil?
      @relationship = Relationship.new(member_id: params[:member_id], event_id: params[:id], status: 1)
    elsif @relationship.status == 0
      @relationship.update(status: 1)
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

   
  private
    def event_params
      params.require(:event).permit(:name, :start_time, :end_time, :fb_event_id, :place_id, :fee)
    end
    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end
    def selected_event
      @event = Event.find(params[:id])
    end

end
