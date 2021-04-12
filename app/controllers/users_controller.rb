class UsersController < ApplicationController
  before_action :active_staff_only, only: [
    :index, :new, :create
  ]
  before_action :authenticate_user!, only: [
    :show, :edit, :update, :destroy,
    :register_event
  ]

  # User list
  def index
    @users = User.all
  end

  # For users
  # My page
  def show
    @user = get_correct_user

    # Get events
    @events = Event.where('start_time > ?', DateTime.now).group(:start_time).order("start_time DESC")
  end

  def edit
    @user = get_correct_user
  end

  def update
    @user = get_correct_user
    if @user.update(user_params)
      # Find member by name and find one or create
      member = Member.from_user(@user)
      @user.update(member_id: member.id)
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
