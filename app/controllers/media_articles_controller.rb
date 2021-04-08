class MediaArticlesController < ApplicationController
  before_action :active_staff_only

  def index
    @media_articles = MediaArticle.paginate(page: params[:page]).order(date: :desc)
  end

  def new
    @media_article = MediaArticle.new
  end

  def create
    @media_article = MediaArticle.new(media_article_params)

    upload_file(@media_article, params[:file])

    if @media_article.save
      redirect_to media_articles_path, :flash => {:success => "Saved!"}
    else
      render 'new'
    end
  end

  def show
    @media_article = MediaArticle.find(params[:id])
  end

  def edit
    @media_article = MediaArticle.find(params[:id])
  end

  def update
    @media_article = MediaArticle.find(params[:id])

    upload_file(@media_article, params[:file])

    if @media_article.update(media_article_params)
      redirect_to media_articles_path , :flash => {:success => 'Saved'}
    else
      flash.now[:error] = 'Invalid email combination'
      render 'edit'
    end
  end

  def destroy
    @media_article = MediaArticle.find(params[:id])
    @media_article.destroy
    redirect_to media_articles_path , :flash => {:success => 'Deleted'}
  end

  def serve_file
    @media_article = MediaArticle.find(params[:id])
    send_data(@media_article.file_data, :type => @media_article.file_mime_type, :filename => "@{@media_article.file_name}", :disposition => "inline")
  end

  def delete_file
    @media_article = MediaArticle.find(params[:id])
    @media_article.update(file_data: nil, file_name: nil, file_mime_type: nil)
    redirect_to media_article_path , :flash => {:success => 'Deleted'}
  end


  private
    def media_article_params
      params.require(:media_article).permit(
        :date, :media, :url, :title, :member_id
      )
    end

    def upload_file(media_article, file)
      if file
        media_article.update(file_data: file.read, file_name: file.original_filename, file_mime_type: file.content_type)
      end
    end

end
