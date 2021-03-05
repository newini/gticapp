class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  private
    def signed_in_user
      redirect_to root_path, notice: "Please sign in." unless signed_in?
    end

    def admin_staff
      redirect_to root_path, notice: "Admin only." unless admin?
    end

    def signed_in_staff
      staff = Staff.find_by_email(current_user.email)
      if not staff.present?
        redirect_to root_path, notice: "Staff only"
      end
    end

    # Behavior after sign in
    def after_sign_in_path_for(resource)
      user_path(resource.id)
    end



end
