class InvitationsController < ApplicationController
  before_action :signed_in_user

  def index
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
      @invitations = @event.invitations.paginate(page:params[:page]).order("created_at DESC")
    else
      #@invitations = Invitation.where(event_id: nil)
      @invitations = Invitation.where(sent_flg: [nil, false]).order("created_at DESC")
    end
  end

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(invitation_params)
    if params[:event_id].present?
      @invitation.event_id = params[:event_id]
    end
    if @invitation.save
      redirect_to invitations_path(@event)
    else
      render 'new'
    end
  end

  def show
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
      @invitation = @event.invitations.find(params[:id])
    else
      @invitation = Invitation.find(params[:id])
    end
  end

  def edit
    @invitation = Invitation.find(params[:id])
  end

  def update
    @invitation = Invitation.find(params[:id])
    if @invitation.update_attributes(invitation_params)
      redirect_to invitations_path(@event, @invitation), :flash => {:success => '変更しました'}
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
    @invitations = Invitation.where(sent_flg: true)
  end

  def send_all
    @invitation = Invitation.find(params[:id])
    sent_cnt = 0
    blank_email_cnt = 0
    Member.where(black_list_flg: [nil, false]).each do |member| # Be careful
      if member.email.present?
        InvitationMailer.send_email_to_each_member(member, @invitation).deliver
        sent_cnt = sent_cnt + 1
      else
        blank_email_cnt = blank_email_cnt + 1
      end
    end
    @invitation.update(sent_flg: true)
    logger.info("send_all, send_cnt: #{sent_cnt}, blank_email_cnt: #{blank_email_cnt}")
    redirect_to invitation_path(@invitation), :flash => {:success => "#{sent_cnt}名の方に送信成功！ #{blank_email_cnt} 名の方にはメールアドレスが空欄であるため送信できませんでした。"}
  end

  def send_test
    @invitation = Invitation.find(params[:id])
    active_user = User.where(active_flg: true)
    sent_cnt = 0
    blank_email_cnt = 0
    Member.where(gtic_flg: true).each do |member| # Test
      active_user.each do |user|
        if member.id == user.member_id
          if member.email.present?
            InvitationMailer.send_email_to_each_member(member, @invitation).deliver
            sent_cnt = sent_cnt + 1
          else
            blank_email_cnt = blank_email_cnt + 1
          end
        end
      end
    end
    redirect_to invitation_path(@invitation), :flash => {:success => "[TEST] #{sent_cnt}名の方に送信成功！ #{blank_email_cnt} 名の方にはメールアドレスが空欄であるため送信できませんでした。"}
  end

  def send_email
    @send_flg = params[:send_flg].to_i
    if @send_flg== 1
      @members = @event.invited_members
      member_mail_address_empty = []
      @members.each do |member|
        if member.email.present?
          InvitationMailer.invitation(member,@event,params[:invitation_id]).deliver
        else
          member_mail_address_empty.push(member.last_name + member.first_name)
        end
        flash[:success] = "メール送信完了！ 以下の方々はメールアドレスが空欄のために送信できませんでした。#{member_mail_address_empty.join(', ')}"
      end
    end
    redirect_to send_invitation_path(@event)
  end


  private
    def invitation_params
      params.require(:invitation).permit(:title, :content)
    end
    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end

end
