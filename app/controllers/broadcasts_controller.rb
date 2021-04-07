class BroadcastsController < ApplicationController
  before_action :active_staff_only

  def index # Get drafts
    @broadcasts = Broadcast.where(sent_flg: [nil, false]).order("created_at DESC")
  end

  def new
    @broadcast = Broadcast.new
  end

  def create
    @broadcast = Broadcast.new(invitation_params)
    if @broadcast.save
      redirect_to broadcast_path(@broadcast), flash: {success: 'saved'}
    else
      render 'new'
    end
  end

  def show
    @broadcast = Broadcast.find(params[:id])
    @events = Event.where.not(cumulative_number: nil).order("created_at DESC")
    @broadcast_members = BroadcastMember.where(broadcast_id: @broadcast.id)
    @birth_months = BroadcastMember.where(broadcast_id: @broadcast.id).pluck(:birth_month).uniq
    @birth_months.delete(0)
    @event_ids = BroadcastMember.where(broadcast_id: @broadcast.id).pluck(:event_id).uniq
    @event_ids.delete(0)
  end

  def edit
    @broadcast = Broadcast.find(params[:id])
  end

  def update
    @broadcast = Broadcast.find(params[:id])
    if @broadcast.update(invitation_params)
      redirect_to broadcast_path(@broadcast), :flash => {:success => '変更しました'}
    else
      render 'edit'
    end
  end

  def destroy
    @broadcast = Broadcast.find(params[:id])
    @broadcast.destroy
    #BroadcastMember.where(broadcast_id: @broadcast.id).delete_all
    redirect_to broadcasts_path, :flash => {:success => '削除しました'}
  end


  # ==========================================
  def sent_list # Get for Collection
    @broadcasts = Broadcast.where(sent_flg: true).order("created_at DESC")
  end

  def show_sent # Get for member
    @broadcast = Broadcast.find(params[:id])
    @events = Event.where.not(cumulative_number: nil).order("created_at DESC")
    @broadcast_members = BroadcastMember.where(broadcast_id: @broadcast.id)
    @birth_months = BroadcastMember.where(broadcast_id: @broadcast.id).pluck(:birth_month).uniq
    @birth_months.delete(0)
    @event_ids = BroadcastMember.where(broadcast_id: @broadcast.id).pluck(:event_id).uniq
    @event_ids.delete(0)
  end

  def broadcast_member_list # Get for member
    @broadcast = Broadcast.find(params[:id])
    broadcast_members = BroadcastMember.where(broadcast_id: @broadcast.id)
    @members = @broadcast.members.paginate(page: params[:page])
  end

  def find_members # get for member
    @broadcast = Broadcast.find(params[:id])
    @broadcast_members = BroadcastMember.where(broadcast_id: @broadcast.id)
    @members = Member.limit(50)
  end

  def search # get for member respond to js
    @broadcast = Broadcast.find(params[:id])
    @broadcast_members = BroadcastMember.where(broadcast_id: @broadcast.id)
    @members = get_search_member(params[:search])
    respond_to :js
  end

  def update_broadcast_member # post for member
    broadcast = Broadcast.find(params[:id])
    member = Member.find(params[:member_id])
    if !checkDuplicatedMember(member.id, broadcast.id)
      BroadcastMember.new(member_id: member.id, broadcast_id: broadcast.id).save
    end
    redirect_to broadcast_member_list_broadcast_path(broadcast), :flash => {:success => "追加しました"}
  end

  def delete_broadcast_member # post for member
    broadcast = Broadcast.find(params[:id])
    member = Member.find(params[:member_id])
    if checkDuplicatedMember(member.id, broadcast.id)
      BroadcastMember.where(broadcast_id: broadcast.id).find_by_member_id(member.id).destroy
    end
    redirect_to broadcast_member_list_broadcast_path(broadcast), :flash => {:success => "削除しました"}
  end

  def add_emails # post for member
    broadcast = Broadcast.find(params[:id])
    emails_origin = params[:emails].to_s.split(";") # Separate emails
    emails = ""
    emails_origin.each do |email|
      if not email.nil?
        if email.include?("<") && email.include?(">")
          res = email.to_s.split("<")
          name = res[0]
          email_address = res[1].tr(">", "").tr(" ", "") # Remove ">" and spaces in email
          mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
          if email_address.match? mailRegex
            emails += ";" if emails != ""
            emails += email
          end
        end
      end
    end
    broadcast.update(emails: emails)
    redirect_to broadcast_path(broadcast), :flash => {:success => "保存しました"}
  end

  def update_include_all_flg # post for member
    @broadcast = Broadcast.find(params[:id])
    if @broadcast.include_all_flg
      # Remove
      BroadcastMember.where(broadcast_id: @broadcast.id).where(include_all_flg: true).delete_all
      # Update
      @broadcast.update(include_all_flg: false)
      redirect_to broadcast_path(@broadcast), :flash => {:success => "参加者全員を外しました。"}
    else
      # Add
      members = Member.where(gtic_flg: [nil, false]).where(black_list_flg: [nil, false]).where.not(email: [nil, ""])
      members.each do |member|
        if !checkDuplicatedMember(member.id, @broadcast.id)
          BroadcastMember.new(member_id: member.id, broadcast_id: @broadcast.id, include_all_flg: true).save
        end
      end
      # Update
      @broadcast.update(include_all_flg: true)
      redirect_to broadcast_path(@broadcast), :flash => {:success => "参加者全員を含めました。"}
    end
  end

  def update_birth_month # post for member
    @broadcast = Broadcast.find(params[:id])
    @broadcast.update(birth_month: params[:birth_month])
    if params[:birth_month] == "00"
      # Remove all
      BroadcastMember.where(broadcast_id: @broadcast.id).where.not(birth_month: 0).delete_all
      redirect_to broadcast_path(@broadcast), :flash => {:success => "誕生月者を外しました。"}
    else
      # Add
      if @broadcast.birth_month >= 1
        birth_month_str = @broadcast.birth_month.to_s.rjust(2, "0")
        members = Member.where(black_list_flg: [nil, false]).where('strftime("%m", birthday) = ?', birth_month_str).where.not(email: [nil, ""])
        members.each do |member|
          if !checkDuplicatedMember(member.id, @broadcast.id)
            BroadcastMember.new(member_id: member.id, broadcast_id: @broadcast.id, birth_month: params[:birth_month]).save
          end
        end
      end
      redirect_to broadcast_path(@broadcast), :flash => {:success => "誕生月者を含めました。"}
    end
  end

  def update_event_id # post for member
    @broadcast = Broadcast.find(params[:id])
    # Update
    @broadcast.update(event_id: params[:event_id])
    if params[:event_id] == "0"
      # Remove
      BroadcastMember.where(broadcast_id: @broadcast.id).where.not(event_id: 0).delete_all
      redirect_to broadcast_path(@broadcast), :flash => {:success => "イベント会合出席者を外しました。"}
    else
      # Add
      if @broadcast.event_id >= 1
        @relationships = Relationship.where(event_id: @broadcast.event_id).where(status: 3) # 出席者
        @relationships.each do |relationship|
          if !checkDuplicatedMember(relationship.member_id, @broadcast.id)
            if Member.where(black_list_flg: [nil, false]).where.not(email: [nil, ""]).find(relationship.member_id).present?
              BroadcastMember.new(member_id: relationship.member_id, broadcast_id: @broadcast.id, event_id: params[:event_id]).save
            end
          end
        end
      end

      redirect_to broadcast_path(@broadcast), :flash => {:success => "イベント会合出席者を含めました。"}
    end
  end

  def update_include_gtic_flg # post for member
    @broadcast = Broadcast.find(params[:id])
    if @broadcast.include_gtic_flg
      # Remove
      BroadcastMember.where(broadcast_id: @broadcast.id).where(include_gtic_flg: true).delete_all
      # Update
      @broadcast.update(include_gtic_flg: false)
      redirect_to broadcast_path(@broadcast), :flash => {:success => "GTICメンバーを外しました。"}
    else
      # Add
      Staff.where(is_active: true).each do |staff|
        if !checkDuplicatedMember(staff.member_id, @broadcast.id)
          BroadcastMember.new(member_id: staff.member_id, broadcast_id: @broadcast.id, include_gtic_flg: true).save
        end
      end
      # Update
      @broadcast.update(include_gtic_flg: true)
      redirect_to broadcast_path(@broadcast), :flash => {:success => "GTICメンバーを含めてました。"}
    end
  end

  def send_email # get for member
    logger.info("Begin of send_email")
    @broadcast = Broadcast.find(params[:id])
    @broadcast.update(sent_at: DateTime.now)

    sent_cnt = 0

    # First, send to broadcast.emails
    logger.info("at broadcast.emails in send_email")
    if @broadcast.emails.present?
      emails = @broadcast.emails.to_s.split(";") # Separate emails
      emails.push("GTIC<gtic.information@gmail.com>")
    else
      emails = ["GTIC<gtic.information@gmail.com>"]
    end
    emails.each do |email|
      if email.present?
        res = email.to_s.split("<")
        name = res[0]
        email_address = res[1].tr(">", "").tr(" ", "") # Remove ">" and spaces in email
        member = Member.find(3347) # Use dami member!
        member.last_name = name
        member.email = email_address
        NoReplyMailer.broadcast(member, @broadcast).deliver
        sent_cnt = sent_cnt + 1
      end
    end

    # Then, send one by one from broadcast_members
    logger.info("at send broadcast_members in send_email")
    sent_failed_members = []
    blank_email_cnt = 0
    broadcast_members = BroadcastMember.where(broadcast_id: @broadcast.id)
    broadcast_members.each do |broadcast_member|
      member = Member.find(broadcast_member.member_id)
      if member.email.present?
        # Validate email address
        mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        if member.email.match? mailRegex
          begin
            NoReplyMailer.broadcast(member, @broadcast).deliver
            broadcast_member.update(sent_flg: true)
            sent_cnt = sent_cnt + 1
          rescue Net::SMTPAuthenticationError
            sleep(1)
            sent_failed_members.push(member)
          end
        end
      else
        blank_email_cnt = blank_email_cnt + 1
      end
    end

    # Try again for failed
    logger.info("at send again in send_email")
    sent_failed_members.each do |member|
      begin
        NoReplyMailer.broadcast(member, @broadcast).deliver
        broadcast_member = BroadcastMember.where(broadcast_id: @broadcast.id).find_by_member_id(member.id)
        broadcast_member.update(sent_flg: true)
        sent_cnt = sent_cnt + 1
      rescue
        sleep(1)
      end
    end

    # Final
    @broadcast.update(sent_flg: true)
    @broadcast.update(sent_cnt: sent_cnt)
    logger.info("End of send_email")
    redirect_to broadcast_path(@broadcast), :flash => {:success =>
                                                         "[TEST] #{sent_cnt}名の方に送信成功！ #{blank_email_cnt} 名の方にはメールアドレスが空欄であるため送信できませんでした。"}
  end # End of send_email


  private
    def invitation_params
      params.require(:broadcast).permit(:subject, :body)
    end

    def checkDuplicatedMember(member_id, broadcast_id)
      if BroadcastMember.where(broadcast_id: broadcast_id).find_by_member_id(member_id).present?
        return true
      end
    end

end
