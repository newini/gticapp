class MembersController < ApplicationController
  before_action :active_staff_only
  helper_method :sort_column, :sort_direction

  def index
    @members = Member.paginate(page: params[:page])
    if params[:count].present?
      @members = Member.joins(:participated_events).group(:member_id).order("count(event_id) DESC").paginate(page: params[:page])
    end
    if params[:affiliation].present?
      @members = Member.order(affiliation: :desc).paginate(page: params[:page])
    end
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def new
    @title = "メンバー登録"
    @member = Member.new
    @referer = params[:referer]
    @event = Event.find(params[:event_id]) if params[:event_id].present?
  end

  def create
    member = Member.new(member_params)
    if member.save
      fill_alphabet_from_kanji_name(member)

      fill_romaji(member)

      # Go back to event page
      if params[:event_id].present?
        if params[:referer] == 'waiting'
          member.relationships.create(event_id: params[:event_id], status: 2)
          redirect_to registed_event_path(params[:event_id])
        elsif params[:referer] == 'add_presenter'
          member.relationships.create(event_id: params[:event_id], status: 2, presentation_role: 1)
          redirect_to event_path(params[:event_id])
        end
      else
        redirect_to member_path(member)
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
    member = Member.find(params[:id])
    # Update facebook name from facebook uid
    if member_params[:uid].present? && (not member.name.present?)
      member.update(name: get_facebook_name(member_params[:uid]))
    end

    # Validate email address
    if member_params[:email].present?
      if not member_params[:email].match? $mailRegex
        flash.now[:error] = 'Invalid email combination'
        render 'edit'
      end
    end

    member.update(member_params)

    fill_alphabet_from_kanji_name(member)

    fill_romaji(member)

    redirect_to member_path , :flash => {:success => '変更しました'}
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

  def upload_profile_picture
    @member = Member.find(params[:id])
    file = params[:file]
    if file
      @member.update(profile_picture_data: file.read, profile_picture_name: file.original_filename, profile_picture_mime_type: file.content_type)
    end
    redirect_to member_path(@member)
  end

  private
    def member_params
      params.require(:member).permit(
        :first_name, :last_name, :first_name_alphabet, :last_name_alphabet,
        :affiliation, :affiliation_eng,
        :category_id, :title,
        :email, :website,
        :facebook_id,
        :biography,
        :note,
        :country_code, :age, :gender, :birthday,
        :azsa_flg, :black_list_flg, :past_presenter_flg, :contributor_flg, :gtic_flg,
        :provider, :uid,
      )
    end

    def sort_column
      Member.column_names.include?(params[:sort]) ? params[:sort] : 'last_name_alphabet'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    # Change member's kanji or hiragana to alphabet
    def fill_alphabet_from_kanji_name(member)
      # Last name
      if not member.last_name_alphabet.present? ||
          ( (member.last_name_alphabet.present?) && (not member.last_name_alphabet.ascii_only?) ) # If not alphabet
        member.update(last_name_alphabet: kanji_to_romaji_jlp(member.last_name).capitalize )
      end
      # First name
      if not member.first_name_alphabet.present? ||
          ( (member.first_name_alphabet.present?) && (not member.first_name_alphabet.ascii_only?) ) # If not alphabet
        member.update(first_name_alphabet: kanji_to_romaji_jlp(member.first_name).capitalize )
      end
    end

    def fill_romaji(member)
      romaji = kanji_to_romaji_jlp(member.last_name) + ',' +
          kanji_to_romaji_jlp(member.first_name) + ',' +
          kanji_to_romaji_jlp(member.affiliation)
      member.update(romaji: romaji)
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

end
