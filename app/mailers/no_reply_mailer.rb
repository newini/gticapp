class NoReplyMailer < ActionMailer::Base
  default from: 'no-reply@gtic.jp'

  def welcome_email
    @user = params[:user]
    @url  = 'https://gtic.jp/users/sign_in'
    mail(to: @user.email, subject: 'Welcome to GTIC')
  end
end
