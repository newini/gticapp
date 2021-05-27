class ImagesController < ApplicationController
  before_action :active_staff_only, except: [:serve]

  def index
    @images = Image.all
  end

  def create
    file = params[:file]
    if file
      image = Image.new(data: file.read, filename: file.original_filename, mime_type: file.content_type)
      # Check dup
      if not Image.find_by_filename(file.original_filename)
        image.save
      end
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    redirect_to images_path, :flash => {:success => 'Deleted'}
  end

  def serve
    if params[:id]
      @image = Image.find(params[:id])
    elsif params[:filename]
      @image = Image.find_by_filename(params[:filename])
    end
    send_data(@image.data, :type => @image.mime_type, :filename => "@{@image.filename}", :disposition => "inline")
  end

end
