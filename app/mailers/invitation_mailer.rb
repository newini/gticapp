class InvitationMailer < ActionMailer::Base
  default from: ENV['MAIL_ADDRESS']

  def send_email_to_each_member(member, invitation)
    @member = member
    @invitation = invitation
    mail(to: @member.email, subject: @invitation.title)
    logger.info("InvitationMailer sent: invitation id: #{@invitation.id}, member id: #{@member.id} , first_name: #{@member.first_name}")
  end

end
