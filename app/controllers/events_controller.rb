class EventsController < ApplicationController
  def index
    @events = Event.paginate(page: params[:page]).order("date DESC")
  end
  def show
    @event = Event.find(params[:id])
    @participants = @event.participants.paginate(page:params[:page]).order("name_kana")
    @presenters = Relationship.where(participated_id: @event.id).where(presenter_flg: true)
  end

  def edit
    @event = Event.find(params[:id]) 
    @participants = @event.participants.paginate(page:params[:page]).order("name_kana")
  end

  def update
    @event = Event.find(params[:id])
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
      redirect_to events_path
    else
      render 'new'
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_path
  end
  
  def import
    Event.import(params[:file])
    redirect_to events_path, :flash => {:success => "インポートされました" }
  end

  def import_participants
    Event.import_participants(params[:file],params[:id]) 
    redirect_to event_path, :flash => {:success => "インポートされました"}
  end

  def change_status
    @event = Event.find(params[:id])
    @member = Member.find(params[:participant_id])
    @relationship = Relationship.where(participated_id: @event.id).find_by_participant_id(@member.id)
      if params[:status] == "true"
        status = false 
      else
        status = true 
      end
      @relationship.presenter_flg = status
      @relationship.save
    redirect_to event_path, :flash => {:success => "更新しました"}
  end

  def participant
    @event = Event.find(params[:id])
    @participants = @event.participants.paginate(page:params[:page]).order("name_kana")
  end

  def invited 
    @event = Event.find(params[:id])
    @invited_members = @event.invited_members.paginate(page:params[:page]).order("name_kana")
  end

  def invite
    @event = Event.find(params[:id])
    @members = Member.all.paginate(page:params[:page]).order("name_kana")
  end

  def change_connection
    @event = Event.find(params[:id])
    @members = Member.all.paginate(page:params[:page]).order("name_kana")
    @member = Member.find(params[:invited_member_id])
    @connection = Connection.where(invited_event_id: @event.id).find_by_invited_member_id(@member.id)
    if @connection.present? == true
      @connection.destroy
    else
      Connection.create(invited_event_id: @event.id, invited_member_id: @member.id)
    end
    
    redirect_to :back, :flash => {:success => "更新しました"}
  end

  def change_all_connection
    @event = Event.find(params[:id])
    @all_members = Member.all
    @all_members.each do |member|
      if Connection.where(invited_event_id: @event.id).find_by_invited_member_id(member.id).blank?
        Connection.create(invited_event_id: @event.id, invited_member_id: member.id) 
      end
    end
    redirect_to :back, :flash => {:success => "更新しました"}
  end

  private
    def event_params
      params.require(:event).permit(:name, :date, :url, :place, :fee, :start_time)
    end

end
