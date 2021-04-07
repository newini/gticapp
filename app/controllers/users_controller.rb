class UsersController < ApplicationController
  before_action :active_staff_only, only: [:index, :new, :create]
  before_action :authenticate_user!, only: [:show, :edit, :update, :destroy]

  # User list
  def index
    @users = User.all
  end

  # For users
  # My page
  def show
    @user = get_correct_user
  end

  def edit
    @user = get_correct_user
  end

  def update
    @user = get_correct_user
    if @user.update(user_params)
      # Find member by name
      member = Member.where(last_name: @user.last_name, first_name: @user.first_name)
      if member.count == 1 # This should have only one
        @user.update(member_id: member[0].id)
 #     else # Create new one rather than
      end
      redirect_to user_path(@user)
    else
      redirect_to edit_user_path(@user)
    end
  end

  def destroy
    @user = get_correct_user
    @user.destroy
    redirect_to root_path , :flash => {:success => 'Deleted'}
  end


  def privacy_policy
  end


  private
    def user_params
      params.fetch(:user, {}).permit(
        :first_name, :last_name, :first_name_alphabet, :last_name_alphabet,
        :affiliation, :title, :category_id, :email,
        :age, :gender, :birthday
      )
    end

    def get_correct_user
      staff = Staff.find_by_uid(current_user.uid)
      if staff.present?   # If Staff
        @user = User.find(params[:id])
      else                # Normal user
        @user = User.find(current_user.id)
      end
    end
end
