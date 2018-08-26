class PresentationsController < ApplicationController
  before_action :signed_in_user

  def index
    @event = Event.find(params[:id])
    @presentations = @event.presentations.order("created_at desc")
    @presenters = @event.presenters
    @presenters_ary = @presenters.map{|presenter| [[presenter.last_name, presenter.first_name].join(" "), presenter.id]}
    respond_to :js
  end

  def new
    @event = Event.find(params[:id])
    @presentation = Presentation.new
    @presenters = @event.presenters
    @presenters_ary = @presenters.map{|presenter| [[presenter.last_name, presenter.first_name].join(" "), presenter.id]}
    respond_to :js
  end

  def create
    @presentation = Presentation.new(presentation_params)
    @event = Event.find(params[:presentation][:event_id])
    presenters = params[:presentation][:member_id]
    if @presentation.save
      presenters.each do |presenter|
        Presentationship.create(presentation_id: @presentation.id, event_id: @event.id, member_id: presenter)
      end
      redirect_to presentations_path(id:@event.id)
    else
      redirect_to :back
    end
  end

  def edit
    @number = params[:number]
    @presentation = Presentation.find(params[:presentation_id])
    @event = Event.find(params[:id])
    @presenters = @event.presenters
    @presenters_ary = @presenters.map{|presenter| [[presenter.last_name, presenter.first_name].join(" "), presenter.id]}
    respond_to do |format|
      format.js 
    end
  end

  def update
    @presentation = Presentation.find(params[:id])
    @event = Event.find(params[:presentation][:event_id])
    @number = params[:presentation][:number]
    presenters = params[:presentation][:member_id]
    if @presentation.update_attributes(presentation_params)
      presentationships = Presentationship.where(presentation_id: @presentation.id)
      presentationships.each do |presentationship|
        presentationship.destroy
      end
      presenters.each do |presenter|
        Presentationship.create(presentation_id: @presentation.id, event_id: @event.id, member_id: presenter)
      end
        redirect_to presentations_path(id: @event.id)
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
