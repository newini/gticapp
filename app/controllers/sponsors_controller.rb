class SponsorsController < ApplicationController
  before_action :active_staff_only

  def index
    @sponsors = Sponsor.all
  end

  def show
    @sponsor = Sponsor.find(params[:id])
  end

  def new
    @sponsor = Sponsor.new
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)

    if @sponsor.save
      redirect_to @sponsor
    else
      render :new
    end
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
  end

  def update
    @sponsor = Sponsor.find(params[:id])

    if @sponsor.update(sponsor_params)
      redirect_to sponsor_path(@sponsor)
    else
      render :edit
    end
  end

  def destroy
    @sponsor = Sponsor.find(params[:id])
    @sponsor.destroy

    redirect_to sponsors_path
  end

  def upload_logo_image
    @sponsor = Sponsor.find(params[:id])
    file = params[:file]
    if file
      @sponsor.update(logo_data: file.read, logo_name: file.original_filename, logo_mime_type: file.content_type)
    end
    redirect_to sponsor_path(@sponsor)
  end

  private
    def sponsor_params
      params.require(:sponsor).permit(
        :name,
        :slogan, :website,
        :description, :note,
        :is_end
      )
    end


end
