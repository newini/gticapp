class Staff < ActiveRecord::Base
  #before_save { self.email = email.downcase }
  #before_create :create_remember_token
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness:{ case_sensitive: false }
  #validates :password, length: { minimum: 6 }
  #has_secure_password

  def Staff.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def Staff.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.create_with_omniauth(auth)
    create! do |staff|
      staff.provider =   auth["provider"]
      staff.uid =        auth["uid"]
      staff.name =       auth["info"]["name"]
      staff.email =      auth["info"]["email"]
      staff.image_url =  auth["info"]["image"]
      staff.access_token = auth["credentials"]["token"]
    end
  end

  private
    def create_remember_token
      self.remember_token = Staff.encrypt(Staff.new_remember_token)
    end

end
