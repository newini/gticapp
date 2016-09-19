class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  
  private
  def signed_in_user
    redirect_to root_path, notice: "Please sign in." unless signed_in?
  end
  def admin_user
    redirect_to root_path, notice: "Admin only." unless admin?
  end

end
