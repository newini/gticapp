class MembersController < ApplicationController
  def index
    @members = Member.paginate(page: params[:page]).order("name_kana")
  end

  def show
    @member = Member.find(params[:id])
  end

  def edit
    @member = Member.find(params[:id]) 
  end

  def update
    @member = Member.find(params[:id])
    if @member.update_attributes(member_params)
      redirect_to member_path , :flash => {:success => '変更しました'}
    else
      render 'edit'
    end
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      redirect_to members_path 
    else
      render 'new'
    end
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    redirect_to members_path
  end

  def import
    Member.import(params[:file])
    redirect_to members_path, :flash => {:success => "インポートされました" }
  end

  def participated
    @member = Member.find(params[:id])
  end

  private
    def member_params
      params.require(:member).permit(:name, :name_kana, :facebook_name, :affiliation, :email)
    end
end
