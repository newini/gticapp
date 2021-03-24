class ManualsController < ApplicationController
  before_action :signed_in_staff

  def index
    @manuals = Manual.all
  end

  def show
    @manuals = Manual.all
    @manual = Manual.find(params[:id])
  end

  def new
    @manuals = Manual.all
    @manual = Manual.new
  end

  def create
    @manual = Manual.new(manual_params)

    if @manual.save
      redirect_to @manual
    else
      render :new
    end
  end

  def edit
    @manuals = Manual.all
    @manual = Manual.find(params[:id])
  end

  def update
    @manual = Manual.find(params[:id])

    if @manual.update(manual_params)
      redirect_to @manual
    else
      render :edit
    end
  end

  def destroy
    @manual = Manual.find(params[:id])
    @manual.destroy

    redirect_to manuals_path
  end


  private
    def manual_params
      params.require(:manual).permit(:title, :body)
    end

end
