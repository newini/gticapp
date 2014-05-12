class MembersController < ApplicationController
  before_action :signed_in_user
  helper_method :sort_column, :sort_direction
  def index
    @members = Member.order(sort_column + ' ' + sort_direction).paginate(page: params[:page])
    if params[:count].present?
      @members = Member.joins(:participated_events).group(:member_id).order("count(event_id) DESC").paginate(page: params[:page])
    end
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def count
    @repeater = []
    ids = []
    #2014年1月1日以降のイベント
    events = Event.where("start_time > ?", Date.parse("2014-01-01"))
    #参加者の全id（重複あり)の配列
    all_participant = events.map{|event| event.participants.map{|member| member.id}}.flatten
    #GTICメンバーのidの配列
    gtic = Member.where(gtic_flg: true).map{|member| member.id}
    #GTICメンバーを排除した参加者idの配列
    participant = all_participant - gtic
    #参加者のidごとにカウントした配列
    repeater_id = participant.map{|id| [id, participant.count(id)]}

#    repeater_id = Member.all.map{|member| [member.id, member.participated_events.where("start_time > ?", Date.parse("2014-01-01").beginning_of_month).count]}
    ids << repeater_id.map{|k,v| k if v >= 5}.compact
    ids << repeater_id.map{|k,v| k if v == 4}.compact
    ids << repeater_id.map{|k,v| k if v == 3}.compact
    ids << repeater_id.map{|k,v| k if v == 2}.compact
    ids.each do |id|
      @repeater << Member.where(id: id)
    end
  end

  def category
  end

  def show
    @member = Member.find(params[:id])
  end

  def edit
    @title = "メンバー情報編集"
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
    @title = "メンバー登録"
    @member = Member.new
    @event = Event.find(params[:event_id]) if params[:event_id].present?
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      if params[:event].present?
        @member.relationships.create(event_id: params[:event][:id], status: 2) 
        redirect_to :back 
      else
        redirect_to :members
      end
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
      if member[:last_name_kana].present?
        last_name_kana = member[:last_name_kana]
      else
        last_name_kana = (member[:last_name].present? && @member.last_name_kana.nil?) ? Member.kana(member[:last_name]) : @member.last_name_kana
      end
      @member.update(first_name: member[:first_name], last_name: member[:last_name], last_name_kana: last_name_kana,  category_id: member[:category_id], affiliation: member[:affiliation], title: member[:title], note: member[:note], email: member[:email])
      @member.save!
    end
    redirect_to :back
  end

  def search
    if params[:search].present? 
      @members = Member.find_name(params[:search]).order("last_name_kana ASC").paginate(page: params[:page])
    else
      @members = Member.order("last_name_kana").paginate(page: params[:page])
    end
    respond_to do |format|
      format.js
    end
  end

  def kana_to_roman
    Rails.logger.level = Logger::DEBUG 
    @members = Member.where.not(last_name_kana: nil)
    total = @members.count
    i = 0
    @members.each do |member|
      if member.last_name_kana.present?
        if member.last_name_kana.ascii_only?
          last_name_alphabet = member.last_name_kana
        else
          last_name_alphabet = roman(member.last_name_kana)
        end
      end
      if member.first_name_kana.present?
        if member.first_name_kana.ascii_only?
          first_name_alphabet = member.first_name_kana
        else
          first_name_alphabet = roman(member.first_name_kana)
        end
      end
      member.update(last_name_alphabet: last_name_alphabet,
                   first_name_alphabet: first_name_alphabet)
      if member.save
        i += 1
      end
    end
    redirect_to members_path, :flash => {:success => "#{i} / #{total}件更新しました" }
  end

  def roman(kana)
    Rails.logger.level = Logger::DEBUG 
    sentence = URI.encode(kana)
    key = 'dj0zaiZpPVR3TzJrbEJzRjRwTCZzPWNvbnN1bWVyc2VjcmV0Jng9OTg-'
    base_url = 'http://jlp.yahooapis.jp/FuriganaService/V1/furigana'
    req_url = "#{base_url}?sentence=#{sentence}&appid=#{key}"
    response = Net::HTTP.get_response(URI.parse(req_url))
    status = Hash.from_xml(response.body)
    words = status["ResultSet"]["Result"]["WordList"]["Word"]
    value = String.new
    logger.debug(words)
    if words.instance_of?(Array)
      words.each do |word|
        if word["Roman"].nil?
          value << word["Surface"]
        else
          value << word["Roman"]
        end
      end
    else
      if words["Roman"].nil?
        value << words["Surface"]
      else
        value << words["Roman"]
      end
    end
    value

  end

  def members(members)
    if current_user.language == 0
      @members = members.sort_by_role_kana
    else
      @members = members.sort_by_role_alphabet
    end
  end

  private
    def member_params
      params.require(:member).permit(
        :first_name, :last_name,:first_name_kana, :last_name_kana, :last_name_alphabet, :first_name_alphabet,
        :facebook_name, :affiliation, :title, :note, :category_id, :email, :black_list_flg, :birthday, :fb_user_id
      )
    end
    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end
    def sort_column
      Member.column_names.include?(params[:sort]) ? params[:sort] : 'last_name_kana'
    end
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end



end
