class NoReplyMailer < ActionMailer::Base
  default from: 'no-reply@gtic.jp'

  def broadcast(member, broadcast)
    @member = member
    @broadcast = broadcast
    mail(to: @member.email, subject: @broadcast.subject)
    logger.info("NoReplyMailer sent: broadcast id: #{@broadcast.id}, member id: #{@member.id} , first_name: #{@member.first_name}")
  end

  def welcome_email
    @user = params[:user]
    @url  = 'https://gtic.jp/users/sign_in'
    mail(to: @user.email, subject: 'Welcome to GTIC')
  end
end
