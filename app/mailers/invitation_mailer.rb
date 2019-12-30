class InvitationMailer < ActionMailer::Base
  default from: ENV['MAIL_ADDRESS']

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def invitation(member,event,invitation)
    @member = member
    @event = event
    @invitation = Invitation.find(invitation)
    mail(to: @member.email, subject: @invitation.title)
  end
end
