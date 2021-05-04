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
      params.require(:staff).permit(
        :member_id, :description,
        :is_admin, :is_active
      )
    end


end
