class EventCategoriesController < ApplicationController
  before_action :signed_in_staff
  def index
    @title = "イベントタイプ一覧"
    @event_categories = EventCategory.all
  end

  def edit
    @title = "イベントタイプ変更"
    @event_category = EventCategory.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @event_category = EventCategory.find(params[:id])
    if @event_category.update_attributes(event_category_params)
      redirect_to :event_categories
    else
      render 'edit'
    end
  end

  def new
    @title = "イベントタイプ登録"
    @event_category = EventCategory.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @event_category = EventCategory.new(event_category_params)
    if @event_category.save
      redirect_to :event_categories
    else
      render 'new'
    end
  end

  def destroy
    @event_category = EventCategory.find(params[:id])
    @event_category.destroy
    redirect_to :event_categories
  end

#--------
  private
#--------
  def event_category_params
    params.require(:event_category).permit(:name)
  end

end
