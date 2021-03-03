module SessionsHelper

  def sign_in(staff)
    remember_token = Staff.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    staff.update_attribute(:remember_token, Staff.encrypt(remember_token))
    self.current_staff = staff
  end

  def signed_in?
    if current_staff.present?
      if session[:expires_at].present?
        if session[:expires_at].to_time > Time.current
          return true
        end
      end
    end
    return false
  end

  def current_staff=(staff)
    @current_staff = staff
  end

  def current_staff
    #remember_token = Staff.encrypt(cookies[:remember_token])
    #@current_staff ||= Staff.find_by(remember_token: remember_token)
    @current_staff ||= Staff.find(session[:staff_id]) if session[:staff_id]
  end

  def sign_out
    self.current_staff = nil
    cookies.delete(:remember_token, :domain=>'gtic.jp')
  end

  def admin?
    current_staff
    @current_staff.admin if current_staff
  end

end
