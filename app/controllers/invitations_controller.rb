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
    @member_invitation_relationships = MemberInvitationRelationship.where(invitation_id: @invitation.id)
    @birth_months = MemberInvitationRelationship.where(invitation_id: @invitation.id).pluck(:birth_month).uniq
    @birth_months.delete(0)
    @event_ids = MemberInvitationRelationship.where(invitation_id: @invitation.id).pluck(:event_id).uniq
    @event_ids.delete(0)
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
    MemberInvitationRelationship.where(invitation_id: @invitation.id).delete_all
    redirect_to invitations_path(), :flash => {:success => '削除しました'}
  end

  def view_sent_emails
    @invitations = Invitation.where(sent_flg: true).order("created_at DESC")
  end

  def view_member_invitation
    @invitation = Invitation.find(params[:id])
    member_invitation_relationships = MemberInvitationRelationship.where(invitation_id: @invitation.id)
    if @invitation.sent_flg
      member_invitation_relationships.where(sent_flg: true)
    end
    @members = []
    member_invitation_relationships.each do |member_invitation_relationship|
      @members.push(Member.find(member_invitation_relationship.member_id))
    end
  end

  def find_members
    @invitation = Invitation.find(params[:id])
    @member_invitation_relationships = MemberInvitationRelationship.where(invitation_id: @invitation.id)
    @members = Member.limit(50)
  end

  def search
    @invitation = Invitation.find(params[:id])
    @member_invitation_relationships = MemberInvitationRelationship.where(invitation_id: @invitation.id)
    if params[:search].present?
      @members = []
      names = params[:search].to_s.split(",")
      names.each do |name|
        words = name.to_s.split(" ")
        words.each_with_index do |w, index|
          if index == 0
            @member = Member.find_member_name(w).order("last_name_alphabet")
          else
            @member = @member.find_member_name(w).order("last_name_alphabet")
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

  def update_member_invitation
    invitation = Invitation.find(params[:id])
    member = Member.find(params[:member_id])
    if !checkDuplicatedMember(member.id, invitation.id)
      MemberInvitationRelationship.new(member_id: member.id, invitation_id: invitation.id).save
    end
    redirect_to view_member_invitation_invitation_path(invitation), :flash => {:success => "追加しました"}
  end

  def delete_member_invitation
    invitation = Invitation.find(params[:id])
    member = Member.find(params[:member_id])
    if checkDuplicatedMember(member.id, invitation.id)
      MemberInvitationRelationship.where(invitation_id: invitation.id).find_by_member_id(member.id).destroy
    end
    redirect_to view_member_invitation_invitation_path(invitation), :flash => {:success => "削除しました"}
  end

  def add_emails
    invitation = Invitation.find(params[:id])
    invitation.update(emails: params[:emails])
    redirect_to invitation_path(invitation), :flash => {:success => "保存しました"}
  end

  def update_include_all_flg
    @invitation = Invitation.find(params[:id])
    if @invitation.include_all_flg
      # Remove
      MemberInvitationRelationship.where(invitation_id: @invitation.id).where(include_all_flg: true).delete_all
      # Update
      @invitation.update(include_all_flg: false)
      redirect_to invitation_path(@invitation), :flash => {:success => "参加者全員を外しました。"}
    else
      # Add
      members = Member.where(black_list_flg: [nil, false]).where.not(email: [nil, ""])
      members.each do |member|
        if !checkDuplicatedMember(member.id, @invitation.id)
          MemberInvitationRelationship.new(member_id: member.id, invitation_id: @invitation.id, include_all_flg: true).save
        end
      end
      # Update
      @invitation.update(include_all_flg: true)
      redirect_to invitation_path(@invitation), :flash => {:success => "参加者全員を含めました。"}
    end
  end

  def update_birth_month
    @invitation = Invitation.find(params[:id])
    @invitation.update(birth_month: params[:birth_month])
    if params[:birth_month] == "00"
      # Remove all
      MemberInvitationRelationship.where(invitation_id: @invitation.id).where.not(birth_month: 0).delete_all
      redirect_to invitation_path(@invitation), :flash => {:success => "誕生月者を外しました。"}
    else
      # Add
      if @invitation.birth_month >= 1
        birth_month_str = @invitation.birth_month.to_s.rjust(2, "0")
        members = Member.where(black_list_flg: [nil, false]).where('strftime("%m", birthday) = ?', birth_month_str)
        members.each do |member|
          if !checkDuplicatedMember(member.id, @invitation.id)
            MemberInvitationRelationship.new(member_id: member.id, invitation_id: @invitation.id, birth_month: params[:birth_month]).save
          end
        end
      end
      redirect_to invitation_path(@invitation), :flash => {:success => "誕生月者を含めました。"}
    end
  end

  def update_event_id
    @invitation = Invitation.find(params[:id])
    # Update
    @invitation.update(event_id: params[:event_id])
    if params[:event_id] == "0"
      # Remove
      MemberInvitationRelationship.where(invitation_id: @invitation.id).where.not(event_id: 0).delete_all
      redirect_to invitation_path(@invitation), :flash => {:success => "イベント会合出席者を外しました。"}
    else
      # Add
      if @invitation.event_id >= 1
  #      @new_members = Member.where.not(:id => @event.relationships.select(:member_id).map(&:member_id))
        @relationships = Relationship.where(event_id: @invitation.event_id).where(status: 3) # 出席者
        @relationships.each do |relationship|
          if !checkDuplicatedMember(relationship.member_id, @invitation.id)
            if Member.where(black_list_flg: [nil, false]).find(relationship.member_id).present?
              MemberInvitationRelationship.new(member_id: relationship.member_id, invitation_id: @invitation.id, event_id: params[:event_id]).save
            end
          end
        end
      end

      redirect_to invitation_path(@invitation), :flash => {:success => "イベント会合出席者を含めました。"}
    end
  end

  def update_include_gtic_flg
    @invitation = Invitation.find(params[:id])
    if @invitation.include_gtic_flg
      # Remove
      MemberInvitationRelationship.where(invitation_id: @invitation.id).where(include_gtic_flg: true).delete_all
      # Update
      @invitation.update(include_gtic_flg: false)
      redirect_to invitation_path(@invitation), :flash => {:success => "GTICメンバーを外しました。"}
    else
      # Add
      User.where(active_flg: true).each do |user|
        if !checkDuplicatedMember(user.member_id, @invitation.id)
          MemberInvitationRelationship.new(member_id: user.member_id, invitation_id: @invitation.id, include_gtic_flg: true).save
        end
      end
      # Update
      @invitation.update(include_gtic_flg: true)
      redirect_to invitation_path(@invitation), :flash => {:success => "GTICメンバーを含めてました。"}
    end
  end

  def send_email
    @invitation = Invitation.find(params[:id])
    @invitation.update(sent_flg: true)
    @invitation.update(sent_at: DateTime.now)

    sent_cnt = 0

    # First, send to invitation.emails
    if @invitation.emails.present?
      emails = @invitation.emails.to_s.split(";") # Separate emails
      emails.each do |email|
        if email.present?
          res = email.to_s.split("<")
          name = res[0]
          email_address = res[1].tr(">", "").tr(" ", "") # Remove ">" and spaces in email
          member = Member.find(1) # TODO shold be improved
          member.last_name = name
          member.email = email_address
          InvitationMailer.send_email_to_each_member(member, @invitation).deliver
          sent_cnt = sent_cnt + 1
        end
      end
    end

    # Then, send one by one from member_invitation_relationships
    blank_email_cnt = 0
    member_invitation_relationships = MemberInvitationRelationship.where(invitation_id: @invitation.id)
    member_invitation_relationships.each do |member_invitation_relationship|
      member = Member.find(member_invitation_relationship.member_id)
      if member.email.present?
        member_invitation_relationship.update(sent_flg: true)
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
      params.require(:invitation).permit(:title, :content)
    end

    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end

    def checkDuplicatedMember(member_id, invitation_id)
      if MemberInvitationRelationship.where(invitation_id: invitation_id).find_by_member_id(member_id).present?
        return true
      end
    end

end
