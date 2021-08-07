class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # To check email format
  $mailRegex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i


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
          #word_romaji = kanji_to_romaji_jlp(word)
          word_romaji = Romaji.kana2romaji(word)
          Event.all.each do |event|
            # Search in presentation
            event_id_hash[event.id] += 15 if event.presentations.search_presentation(word).present?

            # search in presenter's member
            event.presentations.each do |presentation|
              if presentation.presenters
                event_id_hash[event.id] += 15 if presentation.presenters.find_member(word).present?
                event_id_hash[event.id] += 5 if presentation.presenters.search_in_romaji(word_romaji).present?
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
        ma_id_hash = Hash.new(0) # Score for OR search
        words.each do |word|
          word_romaji = Romaji.kana2romaji(word)
          # Find in media article
          MediaArticle.search_media_article(word).each do |ma|
            ma_id_hash[ma.id] += 10
          end

          # Find in members
          MediaArticle.all.each do |ma|
            ma_id_hash[ma.id] += 15 if Member.where(id: ma.member_id).find_member(word).present?
            ma_id_hash[ma.id] += 5 if Member.where(id: ma.member_id).search_in_romaji(word_romaji).present?
          end
        end
        # Sort by score
        ma_ids = ma_id_hash.sort_by{ |e| e[1] }.reverse.map{ |e| e[0] }

        return MediaArticle.where(id: ma_ids).order(Arel.sql(ma_ids.map{ |e| "id="+e.to_s+" DESC" }.join(', ')))
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

    # Convert kanji to romaji by using Suika
    def kanji_to_romaji_suika(word)
      $tagger = Suika::Tagger.new
      if word
        word = word.gsub(/[^\p{Alnum}]/, '') # Remove special characters
        kana_arr = $tagger.parse(word).map{ |w|
          if w.split(',')[-1] != '*'
            w.split(',')[-1] # Get last kana
          else
            w.split("\t")[0] # Get original
          end
        }
        romaji = kana_arr.map{ |k| Romaji.kana2romaji(k) }.join()
        return romaji
      else
        return ''
      end
    end

    # Convert kanji and hiragana to alphabet by using Yahoo api
    # https://developer.yahoo.co.jp/webapi/jlp/furigana/v1/furigana.html
    def kanji_to_romaji_jlp(word)
      if word
        romaji = ''
        word = word.gsub(/[^\p{Alnum}]/, '') # Remove special characters
        sentence = CGI.escape(word) # Convert to ascii
        base_url = 'http://jlp.yahooapis.jp/FuriganaService/V1/furigana'
        req_url = "#{base_url}?sentence=#{sentence}&appid=#{ENV['YAHOO_APPID']}"
        response = Net::HTTP.get_response(URI.parse(req_url)) # Get response
        result_hash = Hash.from_xml(response.body) # Convert xml to hash
        if result_hash["ResultSet"].present?
          word_hashs = result_hash["ResultSet"]["Result"]["WordList"]["Word"]
          logger.info('hgoehasiodfhoshdifh2022')
          logger.info(word_hashs)
          if word_hashs.class == Hash # single word
            # Return romaji, or Original. This happens when word is alphabet
            romaji = (word_hashs['Roman'].present?) ? word_hashs['Roman'].capitalize : word_hashs['Surface']
          else # If hash in array
            romaji = word_hashs.collect { |word|
               (word['Roman'].present?) ? word['Roman'] : word['Surface']
            }.join().capitalize
          end
        end
      end
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
