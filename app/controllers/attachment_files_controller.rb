class AttachmentFilesController < ApplicationController
  before_action :active_staff_only

  def index
    @attachment_files = AttachmentFile.all
  end

  def create
    file = params[:file]
    if file
      attachment_file = AttachmentFile.new(data: file.read, filename: file.original_filename, mime_type: file.content_type)
      # Check dup
      if not AttachmentFile.find_by_filename(file.original_filename)
        attachment_file.save
      end
    end
  end

  def destroy
    @attachment_file = AttachmentFile.find(params[:id])
    @attachment_file.destroy

    redirect_to attachment_files_path, :flash => {:success => 'Deleted'}
  end

  def serve_file
    @attachment_file = AttachmentFile.find_by_filename(params[:filename])
    send_data(@attachment_file.data, :type => @attachment_file.mime_type, :filename => "@{@attachment_file.filename}", :disposition => "inline")
  end

end
