class MembersController < ApplicationController
  before_action :active_staff_only
  helper_method :sort_column, :sort_direction

  def index
    @members = Member.paginate(page: params[:page])
    if params[:count].present?
      @members = Member.joins(:participated_events).group(:member_id).order("count(event_id) DESC").paginate(page: params[:page])
    end
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def new
    @title = "メンバー登録"
    @member = Member.new
    @event = Event.find(params[:event_id]) if params[:event_id].present?
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

  def show
    @member = Member.find(params[:id])
  end

  def edit
    @title = "メンバー情報編集"
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    if member_params[:uid].to_i.to_s == member_params[:uid].to_s # If integer
      @member.update(name: get_facebook_name(member_params[:uid]))
    end
    # Validate email address
    mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    if member_params[:email].present?
      if member_params[:email].match? mailRegex
        @member.update(member_params)
        redirect_to member_path , :flash => {:success => '変更しました'}
      else
        flash.now[:error] = 'Invalid email combination'
        render 'edit'
      end
    else
      @member.update(member_params)
      redirect_to member_path , :flash => {:success => '変更しました'}
    end
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    redirect_to members_path
  end


  # ====================================================
  # List
  def azsa_list
    @members = Member.where(azsa_flg: true).order("last_name_alphabet")
  end

  def no_show_list
    @no_show_members = []
    ids = []
    # All events
    events = Event.all
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
    @members = Member.where(black_list_flg: true).paginate(page: params[:page])
  end

  # ====================================================
  # Statistics
  def count
    @repeater = []
    ids = []
    #2014年1月1日以降のイベント
    #events = Event.where("start_time > ?", Date.parse("2014-01-01"))
    # All events
    events = Event.all
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

  def category
  end


  # ====================================================
  # Action
  def search
    @members = get_search_member(params[:keyword])
    respond_to :js
  end

  # Change member's kanji or hiragana to alphabet
  def fill_alphabet_from_kanji_name
    #@members = Member.where.not(last_name: [nil, ""], first_name: [nil, ""])
    @members = Member.where(id: 3348)
    total = @members.count
    i = 0
    @members.each do |member|
      if not member.last_name_alphabet.present? ||
          ( (member.last_name_alphabet.present?) && (not member.last_name_alphabet.ascii_only?) ) # If not alphabet
        last_name_alphabet = get_alphabet_from_kanji(member.last_name)
        member.update(last_name_alphabet: last_name_alphabet)
        i += 1
      end

      if not member.first_name_alphabet.present? ||
          ( (member.first_name_alphabet.present?) && (not member.first_name_alphabet.ascii_only?) ) # If not alphabet
        first_name_alphabet = get_alphabet_from_kanji(member.first_name)
        member.update(first_name_alphabet: first_name_alphabet)
      end
    end
    redirect_to members_path, :flash => {:success => "#{i} / #{total}件更新しました" }
  end

  # Change kanji and hiragana to alphabet
  # https://developer.yahoo.co.jp/webapi/jlp/furigana/v1/furigana.html
  def get_alphabet_from_kanji(word)
    sentence = CGI.escape(word) # Convert to ascii
    base_url = 'http://jlp.yahooapis.jp/FuriganaService/V1/furigana'
    req_url = "#{base_url}?sentence=#{sentence}&appid=#{ENV['YAHOO_APPID']}"
    response = Net::HTTP.get_response(URI.parse(req_url)) # Get
    result_hash = Hash.from_xml(response.body) # Convert xml to hash
    if result_hash["ResultSet"].present?
      word_hashs = result_hash["ResultSet"]["Result"]["WordList"]["Word"]
      if word_hashs.class == Hash
        return word_hashs['Roman'].capitalize
      else # If hash in array
        return word_hashs.collect { |word| word['Roman']  }.join().capitalize
      end
    else
      ""
    end
  end

  def get_fb_id_from_str(fb_str) # Not use anymore, but keep to know how to get from https
    uri = URI.parse("https://findmyfbid.com/")
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"

    data = {
      "url" => "https://facebook.com/#{fb_str}"
    }.to_json

    req.body = data
    res = http.request(req)

    if res.body.nil? || res.body == "[]"
      return "FAIL"
    else
      id_hash = JSON.parse(res.body)
      return id_hash["id"]
    end
  end


  private
    def member_params
      params.require(:member).permit(
        :first_name, :last_name, :first_name_alphabet, :last_name_alphabet,
        :category_id, :email,
        :biography, :note,
        :affiliation, :title,
        :website,
        :provider, :uid,
        :country_code, :age, :gender, :birthday,
        :azsa_flg, :black_list_flg, :past_presenter_flg, :contributor_flg
      )
    end

    def sort_column
      Member.column_names.include?(params[:sort]) ? params[:sort] : 'last_name_alphabet'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def get_facebook_name(uid)
      oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'], 'https://gtic.jp/')
      graph = Koala::Facebook::API.new(oauth.get_app_access_token)
      begin
        fb_profile = graph.get_connection(uid, '/')
      rescue => e
        return ""
      end
      return fb_profile['name']
    end

end
