class UsersController < ApplicationController
  before_action :signed_in_user, only:[:edit, :update]
  def show
#    @user = User.find(params[:id])
    @user = current_user
  end
  def new
    @user = User.new
  end
  def create
    @user = User.new(user_params)
    if @user.save
      #InvitationMailer.welcome_email(@user).deliver
      sign_in @user
      flash[:success] = "ようこそ GTIC App"
      redirect_to @user
    else
      render 'new'
    end
  end
  def edit
    @user = User.find(params[:id])
  end
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
      redirect_to @user
    else
      render 'edit' 
    end
  end
  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end

end
