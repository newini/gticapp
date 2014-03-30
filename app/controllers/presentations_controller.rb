class PresentationsController < ApplicationController
  before_action :signed_in_user
  def create
    @presentation = Presentation.new(presentation_params)
    @event = Event.find(params[:presentation][:event_id])
    presenters = params[:presentation][:member_id]
    if @presentation.save
      presenters.each do |presenter|
        Presentationship.create(presentation_id: @presentation.id, event_id: @event.id, member_id: presenter)
      end
      redirect_to :back
    else
      redirect_to :back
    end
  end

  def update
    @presentation = Presentation.find(params[:id])
    @event = Event.find(params[:presentation][:event_id])
    presenters = Member.where(id: params[:presentation][:member_id])
    if @presentation.update_attributes(presentation_params)
      presentationships = Presentationship.where(presentation_id: @presentation.id)
      presentationships.each do |presentationship|
        presentationship.destroy
      end
      presenters.each do |presenter|
        Presentationship.create(presentation_id: @presentation.id, event_id: @event.id, member_id: presenter.id)
      end
      redirect_to :back
    else
      redirect_to :back
    end
  end

  def destroy
    @presentation = Presentation.find(params[:id])
    @presentation.destroy
    redirect_to :back
  end

  private
  def presentation_params
    params.require(:presentation).permit(:title, :abstract, :note)
  end


end
