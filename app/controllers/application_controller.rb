class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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

    def get_app_access_token
      uri = URI.parse("https://graph.facebook.com/oauth/access_token?client_id=#{ENV['FACEBOOK_APP_ID']}&client_secret=#{ENV['FACEBOOK_APP_SECRET']}&grant_type=client_credentials")
      request = Net::HTTP::Get.new(uri)
      req_options = { use_ssl: uri.scheme == "https" }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      return JSON.parse(response.body)['access_token']
    end

end
