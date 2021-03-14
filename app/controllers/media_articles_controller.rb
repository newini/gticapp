class MediaArticlesController < ApplicationController
  before_action :signed_in_staff

  def index
    @media_articles = MediaArticle.paginate(page: params[:page]).order(date: :desc)
  end

  def new
    @media_article = MediaArticle.new
    @is_edit = true
  end

  def create
    @media_article = MediaArticle.new(media_article_params)

    upload_file(@media_article, params[:file], media_article_params[:date])

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

    upload_file(@media_article, params[:file], media_article_params[:date])

    if @media_article.update(media_article_params)
      redirect_to media_articles_path , :flash => {:success => 'Saved'}
    else
      flash.now[:error] = 'Invalid email combination'
      render 'edit'
    end
  end

  def destroy
    @media_article = MediaArticle.find(params[:id])
    delete_file(@media_article)
    @media_article.destroy
    redirect_to media_articles_path , :flash => {:success => 'Deleted'}
  end

  def delete_file_path
    @media_article = MediaArticle.find(params[:id])
    delete_file(@media_article)
    redirect_to media_article_path , :flash => {:success => 'Deleted'}
  end

  private
    def media_article_params
      params.require(:media_article).permit(
        :date, :media, :url, :title, :member_id, :file
      )
    end

    def upload_file(media_article, file, date)
      if file.present?
        new_filename = date + "__" + file.original_filename
        output_path = Rails.root.join('public/assets/media_articles', new_filename)

        File.open(output_path, 'w+b') do |fp|
          fp.write  file.read
        end

        # If file_path exist, delete old one
        delete_file(media_article)

        # Update file_path
        media_article.update(file_path: new_filename)
      end
    end

    def delete_file(media_article)
      if media_article.file_path.present?
        begin
          File.open('public/assets/media_articles/'+media_article.file_path, 'r') do |f|
            File.delete(f)
          end
          media_article.update(file_path: nil)
        rescue Errno::ENOENT
        end
      end
    end

end
