class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:facebook] # For facebook login

  belongs_to :member

  after_create :send_welcome_email
  def send_welcome_email
    NoReplyMailer.with(user: self).welcome_email.deliver_now
  end


  def self.from_omniauth(auth)
    User.where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.access_token = auth.credentials.token
      #user.save! # for debug
    end
  end


end
