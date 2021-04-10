class NoReplyMailer < ActionMailer::Base
  default from: 'no-reply@gtic.jp'

  def broadcast(member, broadcast)
    @member = member
    @broadcast = broadcast
    mail(to: @member.email, subject: @broadcast.subject)
    logger.info("NoReplyMailer sent: broadcast id: #{@broadcast.id}, member id: #{@member.id} , first_name: #{@member.first_name}")
  end

  def contact_autoreply(contact)
    @contact = contact
    mail(to: @contact.email, subject: '【自動/auto】<GTIC>お問い合わせ受付完了/Acceptance for CONTACT US')
  end

  def contact_notify(contact)
    @contact = contact
    emails = Staff.where(is_active: true).collect{ |staff| staff.member.email }.join(",")
    mail(to: emails, subject: '【自動/auto】GTIC HP Contact us Notify')
  end

  def deregistration_confirmation(event, member)
    @event = event
    @member = member
    mail(to: @member.email, subject: '【自動/auto】GTIC '+@event.name+'参加登録キャンセル')
  end

  def registration_confirmation(event, member)
    @event = event
    @member = member
    @member_id_hash = generate_hash_from_string(member.id)
    mail(to: @member.email, subject: '【自動/auto】GTIC '+@event.name+'参加登録')
  end


  def welcome_email
    @user = params[:user]
    @url  = 'https://gtic.jp/users/sign_in'
    mail(to: @user.email, subject: '【自動/auto】Welcome to GTIC')
  end

  private
    def generate_hash_from_string(str)
      return Rails.application.message_verifier(ENV['SECRET_KEY_BASE']).generate({ token: str })
    end


end
