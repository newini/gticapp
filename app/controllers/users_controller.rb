class UsersController < ApplicationController
  before_action :signed_in_user, only:[:show, :edit, :update]
  before_action :admin_user, only:[:index, :new, :create]

  def index
    @users = User.all
  end

  def show
    @user = current_user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @member = Member.find(@user.member_id)
    update_else(@user, @member)
    if @user.save
      redirect_to users_path
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @member = Member.find(@user.member_id)
  end

  def update
    @user = User.find(params[:id])
    @member = Member.find(@user.member_id)
    update_else(@user, @member)
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました"
      redirect_to "/users"
    else
      render 'edit'
    end
  end

  def update_active
    user = User.find(params[:id])
    if params[:active_flg]
      user.update(active_flg: true)
    else
      user.update(active_flg: false)
    end
    redirect_to :back
  end

  def update_admin
    user = User.find(params[:id])
    if params[:admin]
      user.update(admin: true)
    else
      user.update(admin: false)
    end
    redirect_to :back
  end

  def update_users
    @users = User.all
    @users.each do |user|
      logger.info(user.id)
      if user.member_id.present?
        logger.info(user.member_id)
        member = Member.find(user.member_id)
        update_else(user, member)
      end
    end
    redirect_to :back
    #redirect_to users_path
  end


  private
    def user_params
      params.require(:user).permit(:name, :email, :uid, :member_id, :description, :admin, :active_flg, :password, :password_confirmation)
    end

    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end

    def update_else(user, member)
      if member.last_name_alphabet.present? and member.first_name_alphabet.present?
        user.update(name: member.first_name_alphabet + " " + member.last_name_alphabet)
      end
      user.update(uid: member.fb_user_id)
      if member.email.present?
        user.update(email: member.email)
      end
      user.save
    end

end
