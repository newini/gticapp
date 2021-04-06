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
    staffs = Staff.where(active_flg: true)
    staffs.each do |staff|
      mail(to: @staff.member.email, subject: '【自動/auto】GTIC HP Contact us Notify')
    end
  end

  def welcome_email
    @user = params[:user]
    @url  = 'https://gtic.jp/users/sign_in'
    mail(to: @user.email, subject: 'Welcome to GTIC')
  end
end
