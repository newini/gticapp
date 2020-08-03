module SessionsHelper

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def signed_in?
    if current_user.present?
      if session[:expires_at].present?
        if session[:expires_at].to_time > Time.current
          return true
        end
      end
    end
    return false
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    #remember_token = User.encrypt(cookies[:remember_token])
    #@current_user ||= User.find_by(remember_token: remember_token)
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token, :domain=>'gtic.jp')
  end

  def admin?
    current_user
    @current_user.admin if current_user
  end

end
