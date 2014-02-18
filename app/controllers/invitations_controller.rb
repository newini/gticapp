class InvitationsController < ApplicationController
  before_action :authenticate_user!
  def index
    @event = Event.find(params[:event_id])
    @invitations = @event.invitations.paginate(page:params[:page]).order("created_at DESC")
  end
  def new
    @event = Event.find(params[:event_id])
    @invitation = Invitation.new
  end
  def create
    @event = Event.find(params[:event_id])
    @invitation = Invitation.new(invitation_params)
    @invitation.event_id = @event.id
    if @invitation.save
      redirect_to event_invitation_path(@event, @invitation)
    else
      render 'new'
    end
  end
  
  def show 
    @event = Event.find(params[:event_id])
    @invitation = @event.invitations.find(params[:id])
  end

  def edit
    @event = Event.find(params[:event_id])
    @invitation = @event.invitations.find(params[:id]) 
  end

  def update
    @event = Event.find(params[:event_id])
    @invitation = @event.invitations.find(params[:id])
    if @invitation.update_attributes(invitation_params)
      redirect_to event_invitation_path(@event, @invitation), :flash => {:success => '変更しました'}
    else
      render 'edit'
    end
  end

  private
    def invitation_params
      params.require(:invitation).permit(:title, :content, :greeting)
    end
    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end



end
