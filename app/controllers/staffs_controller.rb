class StaffsController < ApplicationController
  before_action :active_staff_only
  before_action :admin_staff_only, only:[:new, :create]

  def index
    @staffs = Staff.all
  end

  def show
    @staff = Staff.find(params[:id])
    @member = Member.find(@staff.member_id)
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
      redirect_to "/staffs", :flash => {:success => "ユーザー情報を更新しました"}
    else
      render 'edit'
    end
  end

  def destroy
    @staff = Staff.find(params[:id])
    @staff.destroy
    redirect_to staffs_path, :flash => {:success => 'Deleted'}
  end


  private
    def staff_params
      params.require(:staff).permit(:name, :email, :uid, :member_id, :description, :admin, :active_flg)
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
