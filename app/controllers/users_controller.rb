class UsersController < ApplicationController
  # My page
  def show
    @user = User.find(params[:id])
  end
end
