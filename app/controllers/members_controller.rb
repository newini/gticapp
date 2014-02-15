class MembersController < ApplicationController
  before_action :signed_in_user
  helper_method :sort_column, :sort_direction
  def index
    @members = Member.order(sort_column + ' ' + sort_direction).paginate(page: params[:page])
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
      flash.now[:error] = 'Invalid email/password combination'
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
      params.require(:member).permit(:first_name, :last_name,:first_name_kana, :last_name_kana, :facebook_name, :affiliation, :title, :note, :job, :email, :black_list_flg)
    end
    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end
    def sort_column
      Member.column_names.include?(params[:sort]) ? params[:sort] : 'last_name_kana'
    end
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end


end
