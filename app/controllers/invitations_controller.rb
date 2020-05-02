class InvitationsController < ApplicationController
  before_action :signed_in_user

  def index
    @invitations = Invitation.where(sent_flg: [nil, false]).order("created_at DESC")
  end

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(invitation_params)
    if @invitation.save
      redirect_to invitations_path()
    else
      render 'new'
    end
  end

  def show
    @invitation = Invitation.find(params[:id])
    @events = Event.where.not(cumulative_number: nil).order("created_at DESC")
  end

  def edit
    @invitation = Invitation.find(params[:id])
  end

  def update
    @invitation = Invitation.find(params[:id])
    if @invitation.update_attributes(invitation_params)
      redirect_to invitations_path(@invitation), :flash => {:success => '変更しました'}
    else
      render 'edit'
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy
    redirect_to invitations_path(), :flash => {:success => '削除しました'}
  end

  def view_sent_emails
    @invitations = Invitation.where(sent_flg: true).order("created_at DESC")
  end

  def update_include_all_flg
    @invitation = Invitation.find(params[:id])
    if @invitation.include_all_flg
      @invitation.update(include_all_flg: false)
      redirect_to invitation_path(@invitation), :flash => {:success => "参加者全員を外しました。"}
    else
      @invitation.update(include_all_flg: true)
      redirect_to invitation_path(@invitation), :flash => {:success => "参加者全員を含めました。"}
    end
  end

  def update_birth_month
    @invitation = Invitation.find(params[:id])
    @invitation.update(birth_month: params[:birth_month])
    if params[:birth_month] == 0
      redirect_to invitation_path(@invitation), :flash => {:success => "誕生月者を外しました。"}
    else
      redirect_to invitation_path(@invitation), :flash => {:success => "誕生月者を含めました。"}
    end
  end

  def update_event_id
    @invitation = Invitation.find(params[:id])
    @invitation.update(event_id: params[:event_id])
    if params[:event_id] == 0
      redirect_to invitation_path(@invitation), :flash => {:success => "イベント会合出席者を外しました。"}
    else
      redirect_to invitation_path(@invitation), :flash => {:success => "イベント会合出席者を含めました。"}
    end
  end

  def update_include_gtic_flg
    @invitation = Invitation.find(params[:id])
    if @invitation.include_gtic_flg
      @invitation.update(include_gtic_flg: false)
      redirect_to invitation_path(@invitation), :flash => {:success => "GTICメンバーを外しました。"}
    else
      @invitation.update(include_gtic_flg: true)
      redirect_to invitation_path(@invitation), :flash => {:success => "GTICメンバーを含めてました。"}
    end
  end

  def send_email
    @invitation = Invitation.find(params[:id])
    @invitation.update(sent_flg: true)
    @invitation.update(sent_at: DateTime.now)

    all_members = []
    if @invitation.include_all_flg
      all_members = Member.where(black_list_flg: [nil, false]).where(gtic_flg: [false, nil])
    end

    birth_month_members = []
    if @invitation.birth_month >= 1
      birth_month_str = @invitation.birth_month.to_s.rjust(2, "0")
      birth_month_members = Member.where(black_list_flg: [nil, false]).where('strftime("%m", birthday) = ?', birth_month_str)
    end

    event_members = []
    if @invitation.event_id >= 1
#      @new_members = Member.where.not(:id => @event.relationships.select(:member_id).map(&:member_id))
      @relationships = Relationship.where(event_id: @invitation.event_id).where(status: 3) # 出席者
      @relationships.each do |relationship|
        event_members.push(Member.where(black_list_flg: [nil, false]).find(relationship.member_id))
      end
    end

    gtic_members = []
    gtic_flg = @invitation.include_gtic_flg
    if gtic_flg
      User.where(active_flg: true).each do |user|
        gtic_members.push(Member.find(user.member_id))
      end
    end

    members = all_members + birth_month_members + event_members + gtic_members
    # Remove duplicated members
    @members = members.uniq

    sent_cnt = 0
    blank_email_cnt = 0
    @members.each do |member|
      if member.email.present?
        InvitationMailer.send_email_to_each_member(member, @invitation).deliver
        sent_cnt = sent_cnt + 1
      else
        blank_email_cnt = blank_email_cnt + 1
      end
    end
    @invitation.update(sent_cnt: sent_cnt)
    redirect_to invitation_path(@invitation), :flash => {:success =>
                                                         "[TEST] #{sent_cnt}名の方に送信成功！ #{blank_email_cnt} 名の方にはメールアドレスが空欄であるため送信できませんでした。"}
  end


  private
    def invitation_params
      params.require(:invitation).permit(:title, :content, :month)
    end

    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end

end
