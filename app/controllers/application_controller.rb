class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  # ======================================================
  # Locale
  # https://guides.rubyonrails.org/i18n.html
  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    { locale: I18n.locale  }
  end


  # ======================================================
  private
    # For events
    def get_search_event(keyword)
      record = Event.group(:start_time).order("start_time DESC")
      # Search algorithm
      if keyword.present?
        events = []
        Event.all.order("start_time DESC").each do |event|
          if event.presentations.search_presentation(keyword).present? # Search in presentation
            events.push(event)
          end
          event.presentations.each do |presentation|
            if presentation.presenters.find_member(keyword).present? # search in presenter's member
              if !events.include? event # check duplicate
                events.push(event)
              end
            end
          end
        end
      else
        @start_date = Event.order("start_time ASC").first.start_time.beginning_of_year
        @last_date = Event.order("start_time ASC").last.start_time.end_of_year
      end
      return events
    end

    # For member
    def get_search_member(keyword)
      if keyword.present?
        words = keyword.to_s.split(" ")
        @members = Member.all
        words.each do |word|
          @members = @members.find_member(word).order("last_name_alphabet").paginate(page: params[:page])
        end
        return @members
      else
        return Member.order("last_name_alphabet").paginate(page: params[:page])
      end
    end

    # Make a hash and decode
    def generate_hash_from_string(str)
      return Rails.application.message_verifier(ENV['SECRET_KEY_BASE']).generate({ token: str })
    end

    def verify_string_from_hash(hash)
      return Rails.application.message_verifier(ENV['SECRET_KEY_BASE']).verify(hash)[:token]
    end

    def admin_staff_only
      return if ENV['RAILS_ENV'] == 'development'
      if current_user.present?
        member = Member.where(provider: current_user.provider, uid: current_user.uid).limit(1)
        staff = Staff.find_by_member_id(member.id)
        if staff and staff.is_admin
          return true
        end
      end
      redirect_to :back, notice: "Admin Staff Only."
    end

    def active_staff_only
      return if ENV['RAILS_ENV'] == 'development'
      if current_user.present?
        member = Member.where(provider: current_user.provider, uid: current_user.uid).limit(1)
        staff = Staff.find_by_member_id(member.id)
        if staff and staff.is_active
          return true
        end
      end
      redirect_to root_path, notice: "Active Staff Only."
    end

    # Behavior after sign in
    def after_sign_in_path_for(resource)
      if resource.last_name?
        user_path(resource.id)
      else
        edit_user_path(resource.id)
      end
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
