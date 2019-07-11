class User < ActiveRecord::Base
  #before_save { self.email = email.downcase }
  #before_create :create_remember_token
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness:{ case_sensitive: false }
  #validates :password, length: { minimum: 6 }
  #has_secure_password

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider =   auth["provider"]
      user.uid =        auth["uid"]
      user.name =       auth["info"]["name"]
      user.email =      auth["info"]["email"]
      user.image_url =  auth["info"]["image"]
      user.access_token = auth["credentials"]["token"]
    end
  end

  private
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

end
