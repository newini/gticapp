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
    repeater = participant.map{|id| [id, participant.count(id)]}
    #出席回数でソートした配列(ソートの順番は大->小)
    sorted_repeater =repeater.sort{|a,b| b[1] <=> a[1]}.uniq
    #出席回数をキーにした配列
    transposed_repeater = sorted_repeater.map{|a| [a[1], a[0]]}
    #出席回数でグループ化した配列
    counted_grouped_repeater = transposed_repeater.group_by{|a| a[0]}.map{|k,v| [k,v.map{|a| a[1]}]}
    #配列をハッシュに{回数 => [id, id, ...], 回数 => [id, id, ...], ...}
    @repeater = Hash[counted_grouped_repeater]
=begin
    ids << repeater_id.map{|k,v| k if v >= 5}.compact
    ids << repeater_id.map{|k,v| k if v == 4}.compact
    ids << repeater_id.map{|k,v| k if v == 3}.compact
    ids << repeater_id.map{|k,v| k if v == 2}.compact
    ids.each do |id|
      @repeater << Member.where(id: id)
    end
=end
  end

  def no_show_list
    @no_show_members = []
    ids = []
    #2014年1月1日以降のイベント
    events = Event.where("start_time > ?", Date.parse("2014-01-01"))
    #No showの全id（重複あり)の配列
    all_participant = events.map{|event| event.no_show.map{|member| member.id}}.flatten
    #GTICメンバーのidの配列
    gtic = Member.where(gtic_flg: true).map{|member| member.id}
    #GTICメンバーを排除した参加者idの配列
    participant = all_participant - gtic
    #参加者のidごとにカウントした配列
    no_show_members = participant.map{|id| [id, participant.count(id)]}
    #出席回数でソートした配列(ソートの順番は大->小)
    sorted_repeater =no_show_members.sort{|a,b| b[1] <=> a[1]}.uniq
    #出席回数をキーにした配列
    transposed_repeater = sorted_repeater.map{|a| [a[1], a[0]]}
    #出席回数でグループ化した配列
    counted_grouped_repeater = transposed_repeater.group_by{|a| a[0]}.map{|k,v| [k,v.map{|a| a[1]}]}
    #配列をハッシュに{回数 => [id, id, ...], 回数 => [id, id, ...], ...}
    @no_show_members = Hash[counted_grouped_repeater]
  end

  def black_list
    @black_list_members = Member.where(black_list_flg: true)
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
    if member_params[:fb_user_id].to_i.to_s == member_params[:fb_user_id].to_s
      @member.update(fb_name: get_facebook_name(member_params[:fb_user_id]))
    end
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
      if member[:last_name_alphabet].present?
        last_name_alphabet = member[:last_name_alphabet]
      else
        last_name_alphabet = (member[:last_name].present? && @member.last_name_alphabet.nil?) ? Member.kana(member[:last_name]) : @member.last_name_alphabet
      end
      @member.update(first_name: member[:first_name], last_name: member[:last_name], last_name_alphabet: last_name_alphabet,  category_id: member[:category_id], affiliation: member[:affiliation], title: member[:title], note: member[:note], email: member[:email])
      @member.save!
    end
    redirect_to :back
  end

  def search
    if params[:search].present? 
      words = params[:search].to_s.split(" ")
      words.each_with_index do |w, index|
        if index == 0
          @members = Member.find_member(w).order("last_name_alphabet ASC").paginate(page: params[:page])
        else
          @members = @members.find_member(w).order("last_name_alphabet").paginate(page: params[:page])
        end
      end
    else
      @members = Member.order("last_name_alphabet").paginate(page: params[:page])
    end
    respond_to :js
  end

  def search_participated
    if params[:search].present?
      words = params[:search].to_s.split(" ")
      words.each_with_index do |w, index|
        if index == 0
          @members = Member.find_member(w).order("last_name_alphabet ASC").paginate(page: params[:page])
        else
          @members = @members.find_member(w).order("last_name_alphabet").paginate(page: params[:page])
        end
      end
    else
      @members = Member.where.not(last_name: [nil, ""]).order("last_name_alphabet").paginate(page: params[:page])
    end
    respond_to :js
  end

  def participated_events_list
  end

  def alphabet_to_roman
    Rails.logger.level = Logger::DEBUG 
    @members = Member.where.not(last_name_alphabet: nil)
    total = @members.count
    i = 0
    @members.each do |member|
      if member.last_name_alphabet.present?
        if member.last_name_alphabet.ascii_only?
          last_name_alphabet = member.last_name_alphabet
        else
          last_name_alphabet = roman(member.last_name_alphabet)
        end
      end
      if member.first_name_alphabet.present?
        if member.first_name_alphabet.ascii_only?
          first_name_alphabet = member.first_name_alphabet
        else
          first_name_alphabet = roman(member.first_name_alphabet)
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

  def roman(alphabet)
    Rails.logger.level = Logger::DEBUG 
    sentence = URI.encode(alphabet)
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
    @members = members.sort_by_role_alphabet
  end

  def update_azsa
    member = Member.find(params[:id])
    if params[:azsa_flg]
      member.update(azsa_flg: true)
    else
      member.update(azsa_flg: false)
    end
    redirect_to :back
  end

  def update_past_presenter
    member = Member.find(params[:id])
    if params[:past_presenter_flg]
      member.update(past_presenter_flg: true)
    else
      member.update(past_presenter_flg: false)
    end
    redirect_to :back
  end

  def update_black_list
    member = Member.find(params[:id])
    if params[:black_list_flg]
      member.update(black_list_flg: true)
    else
      member.update(black_list_flg: false)
    end
    redirect_to :back
  end

  def azsa_list
    @members = Member.where(azsa_flg: true)
  end


  private
    def member_params
      params.require(:member).permit(
        :first_name, :last_name, :first_name_alphabet, :last_name_alphabet,
        :facebook_name,  :fb_user_id,
        :affiliation, :title, :note, :category_id, :email, :birthday,
        :black_list_flg, :past_presenter_flg
      )
    end
    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end
    def sort_column
      Member.column_names.include?(params[:sort]) ? params[:sort] : 'last_name_alphabet'
    end
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def get_facebook_name(uid)
      key = current_user.access_token
      graph = Koala::Facebook::API.new(key)
      fb_profile = graph.get_object(member_params[:fb_user_id])
      return fb_profile['name']
    end

end
