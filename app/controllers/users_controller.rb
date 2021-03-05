class UsersController < ApplicationController
  before_action :authenticate_user!

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

  private

    def user_params
      params.fetch(:user, {}).permit(:name)
    end

end
