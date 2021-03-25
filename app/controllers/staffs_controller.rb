class StaffsController < ApplicationController
  before_action :active_staff_only
  before_action :admin_staff_only, only:[:new, :create]

  def index
    @staffs = Staff.all
  end

  def show
    @staff = current_staff
  end

  def new
    @staff = Staff.new
  end

  def create
    @staff = Staff.new(staff_params)
    @member = Member.find(@staff.member_id)
    update_else(@staff, @member)
    if @staff.save
      redirect_to staffs_path
    else
      render 'new'
    end
  end

  def edit
    @staff = Staff.find(params[:id])
    @member = Member.find(@staff.member_id)
  end

  def update
    @staff = Staff.find(params[:id])
    @member = Member.find(@staff.member_id)
    update_else(@staff, @member)
    if @staff.update(staff_params)
      flash[:success] = "ユーザー情報を更新しました"
      redirect_to "/staffs"
    else
      render 'edit'
    end
  end

  def update_active
    staff = Staff.find(params[:id])
    if params[:active_flg]
      staff.update(active_flg: true)
    else
      staff.update(active_flg: false)
    end
    redirect_to :back
  end

  def update_admin
    staff = Staff.find(params[:id])
    if params[:admin]
      staff.update(admin: true)
    else
      staff.update(admin: false)
    end
    redirect_to :back
  end

  def update_staffs
    @staffs = Staff.all
    @staffs.each do |staff|
      logger.info(staff.id)
      if staff.member_id.present?
        logger.info(staff.member_id)
        member = Member.find(staff.member_id)
        update_else(staff, member)
      end
    end
    redirect_to :back
    #redirect_to staffs_path
  end


  private
    def staff_params
      params.require(:staff).permit(:name, :email, :uid, :member_id, :description, :admin, :active_flg, :password, :password_confirmation)
    end

    def update_else(staff, member)
      if member.last_name_alphabet.present? and member.first_name_alphabet.present?
        staff.update(name: member.first_name_alphabet + " " + member.last_name_alphabet)
      end
      staff.update(uid: member.fb_user_id)
      if member.email.present?
        staff.update(email: member.email)
      end
      staff.save
    end

end
