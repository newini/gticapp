class EventsController < ApplicationController
  include EventsHelper
  include MembersHelper
  before_action :signed_in_user
  before_action :find_selected_event,only: [
    :show, :edit, :update, :destroy,
    :change_role, :switch_black_list_flg,
    :update_maybe_member, :update_registed_member, :update_participants,
    :update_birthday,
    :invited, :registed, :participants, :dotasan, :waiting, :maybe, :declined, :dotacan,:no_show,
    :change_status,:change_all_waiting_status,
    :destroy_relationship,
    :send_email,
    :update_facebook, :search, :account,
    :registed_list
  ]

  def index
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
    if params[:year].present?
      year = Date.parse(params[:year])
      base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    else
      base = Event.where(:start_time => @start_date..@last_date).group(:start_time)
    end
#    year = params[:year].present? ? Date.parse(params[:year]) : @last_date
#    base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    record = base.order("start_time DESC")
    @events = record.map{
      |event| [
        event: {
          id: event.id,
          name: event.name,
          date: event.start_time.strftime("%Y-%m-%d"),
          place: event.place_id,
          participants: event.participants.count,
          event_category_id: event.event_category_id
        },
        detail: event.presentations.map{
          |presentation| [
            id: presentation.id,
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.map{
              |presenter| [
                name: [presenter.last_name, presenter.first_name].join(" "),
                affiliation: presenter.affiliation,
                title: presenter.title,
              ]
            }.flatten
          ]
        }.flatten
      ]
    }.flatten
    array = Member.where(:gtic_flg => nil).pluck(:id)
    @total_events = Event.count
    @total_participants = Relationship.where(member_id: array).where(status: 3).count
    @participants = Relationship.where(member_id: array).where(status: 3).group(:member_id).pluck(:member_id).count

    respond_to do |format|
      format.html
      format.js
    end
  end

  # search event
  def search_event
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
    if params[:year].present?
      year = Date.parse(params[:year])
      base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    else
      base = Event.where(:start_time => @start_date..@last_date).group(:start_time)
    end
    record = base.order("start_time DESC")
    @events = record.map{
      |event| [
        event: {
          id: event.id,
          name: event.name,
          date: event.start_time.strftime("%Y-%m-%d"),
          place: event.place_id,
          participants: event.participants.count,
          event_category_id: event.event_category_id
        },
        detail: event.presentations.search_presentation(params[:keyword]).map{
          |presentation| [
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.search_presenter(params[:bio]).map{
              |presenter| [
                name: [presenter.last_name, presenter.first_name].join(" "),
                affiliation: presenter.affiliation,
                title: presenter.title,
              ]
            }.flatten
          ]
        }.flatten
      ]
    }.flatten
    array = Member.where(:gtic_flg => nil).pluck(:id)
    @total_events = Event.count
    @total_participants = Relationship.where(member_id: array).where(status: 3).count
    @participants = Relationship.where(member_id: array).where(status: 3).group(:member_id).pluck(:member_id).count
  end

  def show
    relationship = @event.relationships.find_by_member_id(params[:member_id])
    @participants = @event.participants
    @presentations = @event.presentations.order("created_at desc")
    @presentation = Presentation.new
    @presenters = @event.presenters
    @presenters_ary = @presenters.map{|presenter| [[presenter.last_name, presenter.first_name].join(" "), presenter.id]}
    @registed_members = @event.registed_members
    @graph = facebook_objects(@event.fb_event_id)
    #@fb_event_info = @graph[@event.fb_event_id] if @graph.present?
  end

  def edit
    @title = "イベント情報編集"
    @participants = @event.participants.paginate(page:params[:page]).order("last_name_alphabet")
  end

  def update
    if @event.update_attributes(event_params)
      redirect_to event_path, :flash => {:success => '変更しました'}
    else
      render 'edit'
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to events_path
    else
      render 'new'
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path
  end

  def import
    Event.import(params[:file])
    redirect_to events_path, :flash => {:success => "インポートされました" }
  end

  # Import registed members from FB event page in CSV
  def import_registed_members
    if params[:file].present?
      i, total, problem_names, not_registed_names = Event.import_registed_members(params[:file], params[:id])
      redirect_to registed_event_path, :flash => {:success => "Imported #{i} / #{total} participants. #{problem_names.count} participants with problem: #{problem_names.join("', '")}. Not registed: #{not_registed_names.join("', '")}."}
    else
      redirect_to registed_event_path
    end
  end

  def import_participants
    if params[:file].present?
      i, total, problem_names = Event.import_participants(params[:file], params[:id])
      redirect_to participants_event_path, :flash => {:success => "Imported #{i} / #{total} participants. #{problem_names.count} participants with problem: #{problem_names.join("', '")}."}
    else
      redirect_to participants_event_path
    end
  end

  def import_participants_from_xlsx # CamCard
    if params[:file].present?
      i, total, problem_names = Event.import_participants_from_xlsx(params[:file], params[:id])
      redirect_to participants_event_path, :flash => {:success => "Imported #{i} / #{total} participants. #{problem_names.count} participants with problem: #{problem_names.join("', '")}."}
    else
      redirect_to participants_event_path
    end
  end

  def import_from_questionnaire
    if params[:file].present?
      i, total, problem_names = Event.import_from_questionnaire(params[:file], params[:id])
      redirect_to participants_event_path, :flash => {:success => "Imported #{i} / #{total} participants. #{problem_names.count} participants with problem: #{problem_names.join("', '")}."}
    else
      redirect_to participants_event_path
    end
  end

  def waiting
    @title = "#{@event.name} 参加予定者追加"
    @recorded = Member.recorded_member(@event)
    @members = Member.limit(50)
    @not_found_members = []
    @referer = "waiting"
    respond_to do |format|
      format.js
      format.json { render :json => @members.select(:id, :last_name, :fb_name) }
    end
  end

  def maybe
    @title = "#{@event.name} 未定"
    members(@event.maybe_members)
    @referer = "maybe"
    respond_to do |format|
      format.html
      format.xls {send_data render_to_string(partial: "member_download"),  filename: "#{@title.strip}.xls"}
      format.js
    end
  end

  def registed
    @title = "#{@event.name} 参加予定者"
    members(@event.registed_members)
    @referer = "registed"
    respond_to do |format|
      format.html
      format.xls {send_data render_to_string(partial: "member_download"),  filename: "resisted.xls"}
      format.js
    end
  end

  def participants
    @title = "#{@event.name} 出席者"
    members(@event.participants)
    @referer = "participants"
    respond_to do |format|
      format.html
      format.xls {send_data render_to_string(partial: "member_download"),  filename: "#{@title.strip}.xls"}
      format.js
    end
  end

  def dotasan
    @title = "#{@event.name} ドタ参"
    members(@event.dotasan)
    @referer = "dotasan"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def declined
    @title = "#{@event.name} 欠席者"
    members(@event.declined_members)
    @referer = "declined"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def dotacan
    @title = "#{@event.name} ドタキャン"
    members(@event.dotacan)
    @referer = "dotacan"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def no_show
    @title = "#{@event.name} No-show"
    members(@event.no_show)
    @referer = "no_show"
    respond_to do |format|
      format.html
      format.js
    end
  end

  def change_status
    relationship = @event.relationships.find_by_member_id(params[:member_id])
    direction = params[:direction].to_i
    if relationship.blank?
      relationship = Relationship.new(member_id: params[:member_id], event_id: params[:id], status: 2)
    else
      case direction
      when 0
        relationship.update(status: 0)
      when 2
        relationship.update(status: 2)
      when 3
        relationship.update(status: 3)
      when 4
        relationship.update(status: 4)
      when 5
        relationship.update(status: 5)
      when 6
        relationship.update(status: 6)
      when 7
        relationship.update(status: 7)
      end
    end
    if relationship.save
      select_action(params[:referer])
    end
    #redirect_to :back
    render 'waiting'
  end

  def destroy_relationship
    relationship = @event.relationships.find_by_member_id(params[:member_id])
    if relationship.present?
      relationship.destroy
    end
    redirect_to :back
  end

  def change_role
    relationship = @event.relationships.find_by_member_id(params[:member_id])
    member = Member.find_by_id(params[:member_id])
    case params[:role]
    when "gtic"
      relationship.update(presentation_role: -1)
    when "participant"
      relationship.update(presentation_role: 0)
      member.update(past_presenter_flg: false)
    when "presenter"
      relationship.update(presentation_role: 1)
      member.update(past_presenter_flg: true)
    when "panelist"
      relationship.update(presentation_role: 2)
      member.update(past_presenter_flg: true)
    when "moderator"
      relationship.update(presentation_role: 3)
      member.update(past_presenter_flg: true)
    when "guest"
      relationship.update(presentation_role: 4)
      member.update(past_presenter_flg: false)
    when "past_presenter"
      relationship.update(presentation_role: 5)
      member.update(past_presenter_flg: true)
    end
#    if relationship.save
#      select_action(params[:referer])
#    else
      redirect_to :back
#    end
  end

  def switch_black_list_flg
    member = Member.find(params[:member_id])
    flg = member.black_list_flg == true ? false : true
    member.update(black_list_flg: flg)
    if member.save
      select_action(params[:referer])
    else
      redirect_to :back
    end
  end

  def change_all_waiting_status
    @members = @event.waiting_members.where(black_list_flg: false).where("email IS NOT NULL").order("last_name_alphabet")
    @members.each do |member|
      relationship = @event.relationships.find_by_member_id(member.id)
      if relationship.status == 0
        relationship.update(status: 1)
      end
      relationship.save
    end
    redirect_to :back, :flash => {:success => "更新しました"}
  end

  def update_facebook
    status_array = ["attending", "maybe", "declined"]
    status_array.each do |rsvp_status|
      fb_members = facebook(@event.fb_event_id, rsvp_status)
      fb_members.each do |fb_member|
        fb_name = fb_member["name"]
        fb_user_id = fb_member["id"]
        if Member.find_by_fb_user_id(fb_user_id).present?
          member = Member.find_by_fb_user_id(fb_member["id"])
          member.update(fb_name: fb_name, fb_user_id: fb_user_id)
        else
          member = Member.new(fb_name: fb_name, fb_user_id: fb_user_id)
        end
        member.save!
        if record = member.relationships.find_by_event_id(@event.id)
          unless record.status == convert_status(rsvp_status)
            case record.status
            when nil, 0, 1, 2
                record.update(event_id: @event.id, status: convert_status(rsvp_status))
                record.save!
            end
          end
        else
          member.relationships.create(event_id: @event.id, status: convert_status(rsvp_status))
        end

      end
    end
    redirect_to :back
  end

  def search
    @title = "#{@event.name} 参加予定者追加"
    @recorded = Member.recorded_member(@event)
    if params[:search].present?
      @members = []
      @not_found_members = []
      names = params[:search].to_s.split(",")
      names.each do |name|
        words = name.to_s.split(" ")
        words.each_with_index do |w, index|
          if index == 0
            @member = Member.find_member(w).order("last_name_alphabet")
          else
            @member = @member.find_member(w).order("last_name_alphabet")
          end
        end
        if @member.empty?
          @not_found_members.push(name)
        end
        @members += @member
      end
    else
      @members = Member.order("last_name_alphabet").limit(50)
    end
    respond_to :js
  end

  def update_maybe_member
    @title = "#{@event.name} 未定者情報編集"
    @members = @event.maybe_members.order("last_name_alphabet")
    respond_to :js
  end

  def update_registed_member
    @title = "#{@event.name} 参加予定者情報編集"
    @members = @event.registed_members.order("last_name_alphabet")
    respond_to :js
  end

  def update_participants
    @title = "#{@event.name} 出席者情報編集"
    @members = @event.participants.order("last_name_alphabet")
    respond_to :js
  end

  def update_birthday
    member = Member.find(params[:member_id])
    if params[:birthday]
      member.update(birthday: @event.start_time.beginning_of_month)
    else
      member.update(birthday: nil)
    end
    if member.save
      select_action(params[:referer])
    end
  end

  def update_black_list
    member = Member.find(params[:member_id])
    if params[:black_list_flg]
      member.update(black_list_flg: true)
    else
      member.update(black_list_flg: false)
    end
    redirect_to :back
  end

  def statistics
    @title = "統計"
    if params[:id].present?
      @event = Event.find(params[:id])
      record = @event.participants.group(:category_id).count
      @category = record.map{|key,val| [key.present? ? Category.find(key).name : "未登録", val]}
      membership = @event.relationships.where("status = 2 or status = 3")
      @date_count = membership.group("date(created_at)").count.map{|key,val| [key,val]}
    else
      @events = Event.all
      category = @events.map{|event| event.id}
      @participants = @events.map{|event| [event.id, event.participants.count] }
      @no_show = @events.map{|event| [event.id, event.no_show.count] }
      @maybe = @events.map{|event| [event.id, event.maybe_members.count] }
      @declined = @events.map{|event| [event.id, event.declined_members.count] }
    end
  end

  def account
    @title = "会計"
    range = @event.start_time.beginning_of_month..@event.start_time.end_of_month
    fee = @event.fee || 0
    participants = @event.participants
    participant = participants.pluck(:id)
    presenter = @event.relationships.where(status: 3).where(presentation_role: 1).pluck(:member_id)
    guest = @event.relationships.where(status: 3).where(guest_flg: true).pluck(:member_id)
    gtic = participants.where(gtic_flg: true).pluck(:id)
    free = (presenter + guest + gtic).uniq
    student = participants.where(category_id: 10).pluck(:id) - free
    birthday = participants.where(birthday: range).pluck(:id) - free

    if @event.registers.blank?
      Register.create( event_id: @event.id, account_id: 1, amount: participant.count * fee )
      Register.create( event_id: @event.id, account_id: 2, amount: gtic.count * fee )
      Register.create( event_id: @event.id, account_id: 3, amount: presenter.count * fee )
      Register.create( event_id: @event.id, account_id: 4, amount: guest.count * fee )
      Register.create( event_id: @event.id, account_id: 5, amount: student.count * 1000 )
      Register.create( event_id: @event.id, account_id: 6, amount: birthday.count * 1000 )
    end
    @registers_pos = @event.registers.joins(:account).where("accounts.positive =?", true)
    @registers_neg = @event.registers.joins(:account).where("accounts.positive =?", false)
  end

  def registed_list
    @title = "#{@event.name} 参加予定者"
    members(@event.registed_members)
    @referer = "registed"
    relationship = @event.relationships.find_by_member_id(params[:member_id])
  end


  def download
    @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
    @last_date = Event.order("start_time ASC").last.start_time.end_of_year
    if params[:year].present?
      year = Date.parse(params[:year])
      base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    else
      base = Event.where(:start_time => @start_date..@last_date).group(:start_time)
    end
#    year = params[:year].present? ? Date.parse(params[:year]) : @last_date
#    base = Event.where(:start_time => year.beginning_of_year..year.end_of_year).group(:start_time)
    record = base.order("start_time DESC")
    @events = record.map{
      |event| [
        event: {
          id: event.id,
          name: event.name,
          date: event.start_time.strftime("%Y-%m-%d"),
          place: event.place_id,
          participants: event.participants.count,
          event_category_id: event.event_category_id
        },
        detail: event.presentations.map{
          |presentation| [
            title: presentation.try(:title),
            abstract: presentation.try(:abstract),
            note: presentation.try(:note),
            presenter: presentation.presenters.map{
              |presenter| [
                name: [presenter.last_name, presenter.first_name].join(" "),
                affiliation: presenter.affiliation,
                title: presenter.title,
              ]
            }.flatten
          ]
        }.flatten
      ]
    }.flatten
    array = Member.where(:gtic_flg => nil).pluck(:id)
    @total_events = Event.count
    @total_participants = Relationship.where(member_id: array).where(status: 3).count
    @participants = Relationship.where(member_id: array).where(status: 3).group(:member_id).pluck(:member_id).count

    respond_to do |format|
      format.html
      format.xls {send_data render_to_string(partial: "event_download"),  filename: "events.xls"}
      format.js
    end
  end

  def fb
    status = "invited"
      #GIFワークショップのイベントID
    @event_id = "226471170876676"
      #招待された人を格納["id",...]
    invited = facebook(@event_id, status).map{|v| v["id"].to_i}
      #GTICメンバーを格納["uid",...]
    organizer = User.all.map{|v| v.uid.to_i}
      #大野さんを追加
    organizer.push(100001988359323)
      #削除する人を格納["id",...]
    @deleting = invited - organizer
    @app_id = Settings.OmniAuth.facebook.app_id
    access_token = "CAAKLIo4ZCd3gBAJpRrnGhyUeWV3KWehqezNdLXGP7eZBPy9uJ4LLmKnT0Pbu2sdLz78OYG1UyhKLLHZB1Wq9oqjLuIkqSxI2fgQbcvYhrBmJ3E7qmBTSPl8y7QnVTnRDYgJZCOJnqtPEmxOVaqfRXa4kyKhGJJ04h9i1EbkyhggEGcEROyHq"
  end

=begin
  def convert
    @presentations = Presentation.all
    @presentations.each do |presentation|
      event_id = presentation.event_id
      member_id = presentation.member_id
      presentation_id = presentation.id
      presentationship = Presentationship.where(event_id: event_id).find_by_member_id(member_id) || Presentationship.new(event_id: event_id, member_id: member_id)
      presentationship.update(presentation_id: presentation_id)
      presentationship.save
    end
    redirect_to events_path
  end
=end
  def members(members)
      @members = members.sort_by_role_alphabet
  end

  private
    def event_params
      params.require(:event).permit(:name, :start_time, :end_time, :fb_event_id, :place_id, :fee, :event_category_id, :note)
    end
    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end
    def find_selected_event
      if params[:id].present?
        @event = Event.find(params[:id])
      elsif params[:event_id].present?
        @event = Event.find(params[:event_id])
      end
    end

    def select_action(referer)
      case referer
      when "maybe"
        maybe
      when "registed"
        registed
      when "participants"
        participants
      when "dotasan"
        dotasan
      when "declined"
        declined
      when "dotacan"
        dotacan
      when "no_show"
        no_show
      end
    end
end
