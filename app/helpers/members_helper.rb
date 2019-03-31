module MembersHelper

  def check_member_flg(event)
    presenter_flg = Relationship.where(event_id: event.id).find_by_member_id(@member).presenter_flg
    if presenter_flg == true
      "○"
    else
      "x"
    end
  end

  def kana(kanji)
    sentence = kanji
    sentence = URI.encode(sentence)
    key = 'dj0zaiZpPVR3TzJrbEJzRjRwTCZzPWNvbnN1bWVyc2VjcmV0Jng9OTg-'
    base_url = 'http://jlp.yahooapis.jp/FuriganaService/V1/furigana'
    req_url = "#{base_url}?sentence=#{sentence}&appid=#{key}"
    response = Net::HTTP.get_response(URI.parse(req_url))
    status = Hash.from_xml(response.body)
    words = status["ResultSet"]["Result"]["WordList"]["Word"]
    value = String.new
    words.each do |word|
      if word["Furigana"].nil?
        value << word["Surface"]
      else
        value << word["Furigana"]
      end
    end
    value
  end

end
