class PlacesController < ApplicationController
  before_action :signed_in_staff
  def index
    @title = "会場一覧"
    @places = Place.all
  end

  def edit
    @title = "会場名変更"
    @place = Place.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @place = Place.find(params[:id])
    if @place.update(place_params)
      redirect_to :places
    else
      render 'edit'
    end
  end

  def new
    @title = "会場登録"
    @place = Place.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @place = Place.new(place_params)
    if @place.save
      redirect_to :places
    else
      render 'new'
    end
  end

  def destroy
    @place = Place.find(params[:id])
    @place.destroy
    redirect_to :places
  end

#--------
  private
#--------
  def place_params
    params.require(:place).permit(:name)
  end

end
