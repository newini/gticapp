class MembersController < ApplicationController

  before_action :signed_in_user
  helper_method :sort_column, :sort_direction
  def index
    @members = Member.order(sort_column + ' ' + sort_direction).paginate(page: params[:page])
    if params[:count].present?
      @members = Member.joins(:registed_events).group(:member_id).order("count(event_id) DESC").paginate(page: params[:page])
    end
    @all_members = Member.all
    respond_to do |format|
      format.html
      format.xls
    end
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

  def management
    @categories = Category.all
  end

  def update_information
    params[:member].each do |member|
      @member = Member.find(member[:id])
      last_name_kana = (member[:last_name].present? && @member.last_name_kana.nil?) ? Member.kana(member[:last_name]) : @member.last_name_kana
      @member.update(first_name: member[:first_name], last_name: member[:last_name], last_name_kana: last_name_kana,  category_id: member[:category_id], affiliation: member[:affiliation], title: member[:title], note: member[:note], email: member[:email])
      @member.save!
    end
    redirect_to :back
  end

  private
    def member_params
      params.require(:member).permit(:first_name, :last_name,:first_name_kana, :last_name_kana, :facebook_name, :affiliation, :title, :note, :category_id, :email, :black_list_flg)
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
