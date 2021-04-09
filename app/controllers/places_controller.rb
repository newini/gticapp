class PlacesController < ApplicationController
  before_action :active_staff_only

  def index
    @places = Place.all
  end

  def new
    @title = "新規会場登録"
    @place = Place.new
  end

  def create
    @place = Place.new(place_params)
    if @place.save
      redirect_to :places
    else
      render 'new'
    end
  end

  def show
    @place = Place.find(params[:id])
  end

  def edit
    @title = "会場情報修正"
    @place = Place.find(params[:id])
  end

  def update
    @place = Place.find(params[:id])
    if @place.update(place_params)
      redirect_to :places
    else
      render 'edit'
    end
  end


  def destroy
    @place = Place.find(params[:id])
    @place.destroy
    redirect_to :places
  end


  private
    def place_params
      params.require(:place).permit(
        :name, :address, :city, :nearest_station, :how_to_go,
        :latitude, :longitude
      )
    end

end
