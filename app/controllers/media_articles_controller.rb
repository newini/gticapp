class MediaArticlesController < ApplicationController
  before_action :signed_in_user

  def index
    @media_articles = MediaArticle.all.order(date: :desc)
  end

  def new
    @media_article = MediaArticle.new
    @is_edit = true
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
    @is_edit = false
  end

  def edit
    @media_article = MediaArticle.find(params[:id])
    @is_edit = true
  end

  def update
    @media_article = MediaArticle.find(params[:id])

    upload_file(@media_article, params[:file])

    if @media_article.update_attributes(media_article_params)
      redirect_to media_articles_path , :flash => {:success => 'Saved'}
    else
      flash.now[:error] = 'Invalid email combination'
      render 'edit'
    end
  end

  def destroy
  end

  private
    def media_article_params
      params.require(:media_article).permit(
        :date, :media, :url, :title, :member_id, :file
      )
    end

    def upload_file(media_article, file)
      if file.present?
        new_filename = file.original_filename.gsub(/[^0-9]/,"") + ".pdf"
        output_path = Rails.root.join('public/assets/media_articles', new_filename)

        File.open(output_path, 'w+b') do |fp|
          fp.write  file.read
        end

        media_article.update(file_path: new_filename)
      end
    end

end
