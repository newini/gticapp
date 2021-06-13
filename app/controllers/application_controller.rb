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
      if keyword.present?
        events = Event.all
        words = keyword.tr("０-９Ａ-Ｚａ-ｚ　", "0-9A-Za-z ").to_s.split(" ")
        words.each do |word|
          event_ids = []
          events.all.each do |event|
            if event.presentations.search_presentation(word).present? # Search in presentation
              event_ids.push(event.id)
              next
            end
            event.presentations.each do |presentation|
              if presentation.presenters.find_member(word).present? # search in presenter's member
                event_ids.push(event.id) if not event_ids.include? event.id # check duplicate
              end
            end
          end
          events = Event.where(id: event_ids).order("start_time DESC")
        end
        return events
      else
        return nil
      end
    end

    # For member
    def get_search_member(keyword)
      if keyword.present?
        members = Member.all
        words = keyword.tr("０-９Ａ-Ｚａ-ｚ　", "0-9A-Za-z ").to_s.split(" ")
        words.each do |word|
          members = members.find_member(word).order("last_name_alphabet").paginate(page: params[:page])
        end
        return members
      else
        return Member.paginate(page: params[:page])
      end
    end

    # For media article
    def get_search_media_article(keyword)
      if keyword.present?
        media_articles = MediaArticle.all
        words = keyword.tr("０-９Ａ-Ｚａ-ｚ　", "0-9A-Za-z ").to_s.split(" ")
        words.each do |word|
          media_article_ids = media_articles.search_media_article(word).map{ |ma| ma.id }
          media_articles.all.each do |media_article|
            if Member.where(id: media_article.member_id).find_member(word).present? # Search in member
              media_article_ids.push(media_article.id) if not media_article_ids.include? media_article.id
            end
          end
          media_articles = MediaArticle.where(id: media_article_ids).order(date: :desc)
        end
        return media_articles
      else
        return nil
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
        member = Member.where(provider: current_user.provider, uid: current_user.uid).first
        staff = Staff.find_by_member_id(member.id) if member
        if staff and staff.is_admin
          return true
        end
      end
      redirect_to :back, notice: "Admin Staff Only."
    end

    def active_staff_only
      return if ENV['RAILS_ENV'] == 'development'
      if current_user.present?
        member = Member.where(provider: current_user.provider, uid: current_user.uid).first
        staff = Staff.find_by_member_id(member.id) if member
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
