class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # To check email format
  $mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  # Kanji to kana
  # Declare hear, only once due to slow down
  $tagger = Suika::Tagger.new


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
    # Search for events
    def get_search_event(keyword)
      if keyword.present?
        words = keyword.tr("０-９Ａ-Ｚａ-ｚ　", "0-9A-Za-z ").to_s.split(" ")
        event_id_hash = Hash.new(0) # Score for OR search
        words.each do |word|
          word_romaji = kanji_to_romaji(word)
          Event.all.each do |event|
            # Search in presentation
            event_id_hash[event.id] += 15 if event.presentations.search_presentation(word).present?

            # search in presenter's member
            event.presentations.each do |presentation|
              if presentation.presenters
                event_id_hash[event.id] += 15 if presentation.presenters.find_member(word).present?
              end
            end

            # Search in place
            event_id_hash[event.id] += 10 if event.place.name.match(word)
          end
        end
        #event_id_hash = event_id_hash.filter{ |k,v| v >= 10 } if event_id_hash.count >= 10
        # Sort by score
        event_ids = event_id_hash.sort_by{ |e| e[1] }.reverse.map{ |e| e[0] }
        return Event.where(id: event_ids).order(Arel.sql(event_ids.map{ |e| "id="+e.to_s+" DESC" }.join(', ')))
      else
        return nil
      end
    end

    # Search for member
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

    # Search for media article
    def get_search_media_article(keyword)
      if keyword.present?
        words = keyword.tr("０-９Ａ-Ｚａ-ｚ　", "0-9A-Za-z ").to_s.split(" ")
        media_article_id_hash = Hash.new(0) # Score for OR search
        words.each do |word|
          # Find in media article
          MediaArticle.search_media_article(word).each do |media_article|
            media_article_id_hash[media_article.id] += 10
          end

          # Find in members
          MediaArticle.all.each do |media_article|
            media_article_id_hash[media_article.id] += 15 if Member.where(id: media_article.member_id).find_member(word).present?
          end
        end
        # Sort by score
        media_article_ids = media_article_id_hash.sort_by{ |e| e[1] }.reverse.map{ |e| e[0] }

        return MediaArticle.where(id: media_article_ids).order(Arel.sql(media_article_ids.map{ |e| "id="+e.to_s+" DESC" }.join(', ')))
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

    # Kanji to romaji
    def kanji_to_romaji(word)
      kana_arr = $tagger.parse(word).map{ |w|
        if w.split(',')[-1] != '*'
          w.split(',')[-1] # Get last kana
        else
          w.split("\t")[0] # Get original
        end
      }
      romaji = kana_arr.map{ |k| Romaji.kana2romaji(k) }.join()
      return romaji
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
