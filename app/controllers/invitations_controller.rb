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
    @events = Event.all.order("created_at DESC")
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

  def send_all
    @invitation = Invitation.find(params[:id])
    sent_cnt = 0
    blank_email_cnt = 0
    @members = Member.where(black_list_flg: [nil, false])
    if !@invitation.include_gtic_flg
      @members = @members.where(gtic_flg: [false, nil])
    end
    @member.each do |member| # Be careful
      if member.email.present?
        InvitationMailer.send_email_to_each_member(member, @invitation).deliver
        sent_cnt = sent_cnt + 1
      else
        blank_email_cnt = blank_email_cnt + 1
      end
    end
    @invitation.update(sent_flg: true)
    @invitation.update(sent_at: Time.now)
    logger.info("send_all, send_cnt: #{sent_cnt}, blank_email_cnt: #{blank_email_cnt}")
    redirect_to invitation_path(@invitation), :flash => {:success =>
                                                         "#{sent_cnt}名の方に送信成功！ #{blank_email_cnt} 名の方にはメールアドレスが空欄であるため送信できませんでした。"}
  end

  def send_birth_month
    @invitation = Invitation.find(params[:id])
    @month = params[:month]
    @members = Member.where(black_list_flg: [nil, false]).where('strftime("%m", birthday) = ?', @month)
    if @invitation.include_gtic_flg
      active_users = User.where(active_flg: true)
      active_users.each do |user|
        @members.push(Member.find(user.member_id))
      end
    end
    sent_cnt = 0
    blank_email_cnt = 0
    @members.each do |member|
      if member.email.present?
        #InvitationMailer.invitation(member, @invitation).deliver
        sent_cnt = sent_cnt + 1
      else
        blank_email_cnt = blank_email_cnt + 1
      end
    end
    @invitation.update(sent_flg: true)
    @invitation.update(sent_at: Time.now)
    redirect_to invitation_path(@invitation), :flash => {:success =>
                                                         "[TEST] #{sent_cnt}名の方に送信成功！ #{blank_email_cnt} 名の方にはメールアドレスが空欄であるため送信できませんでした。"}
  end

  def send_event
    @invitation = Invitation.find(params[:id])
#    @new_members = Member.where.not(:id => @event.relationships.select(:member_id).map(&:member_id))
    @relationships = Relationship.where(event_id: params[:event_id]).where(status: 3) # 出席者
    @members = []
    @relationships.each do |relationship|
      @members.push(Member.find(relationship.member_id))
    end
    if @invitation.include_gtic_flg
      active_users = User.where(active_flg: true)
      active_users.each do |user|
        @members.push(Member.find(user.member_id))
      end
    end
    sent_cnt = 0
    blank_email_cnt = 0
    @members.each do |member|
      if member.email.present?
        #InvitationMailer.invitation(member, @invitation).deliver
        sent_cnt = sent_cnt + 1
      else
        blank_email_cnt = blank_email_cnt + 1
      end
    end
    @invitation.update(sent_flg: true)
    @invitation.update(sent_at: DateTime.now)
    redirect_to invitation_path(@invitation), :flash => {:success =>
                                                         "[TEST] #{sent_cnt}名の方に送信成功！ #{blank_email_cnt} 名の方にはメールアドレスが空欄であるため送信できませんでした。"}
  end

  def send_test
    @invitation = Invitation.find(params[:id])
    active_users = User.where(active_flg: true)
    sent_cnt = 0
    blank_email_cnt = 0
    active_users.each do |user|
      member = Member.find(user.member_id)
      if member.email.present?
        InvitationMailer.send_email_to_each_member(member, @invitation).deliver
        sent_cnt = sent_cnt + 1
      else
        blank_email_cnt = blank_email_cnt + 1
      end
    end
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
