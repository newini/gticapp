class UsersController < ApplicationController
  before_action :signed_in_staff, only: [:index, :new, :create]
  before_action :authenticate_user!, only: [:show, :edit, :update, :destroy]

  # User list
  def index
    @users = User.all
  end

  # For users
  # My page
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if current_user.update(user_params)
      redirect_to user_path(current_user)
    else
      redirect_to edit_user_path(current_user)
    end
  end

  def privacy_policy
  end


  private
    def user_params
      params.fetch(:user, {}).permit(:name)
    end

end
