class CategoriesController < ApplicationController
  before_action :active_staff_only
  def index
    @title = "メンバーカテゴリー（属性）一覧"
    @categories = Category.all
  end

  def edit
    @title = "メンバーカテゴリー名変更"
    @category = Category.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      redirect_to :categories
    else
      render 'edit'
    end
  end

  def new
    @title = "メンバーカテゴリー登録"
    @category = Category.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to :categories
    else
      render 'new'
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to :categories
  end

#--------
  private
#--------
  def category_params
    params.require(:category).permit(:name)
  end


end
