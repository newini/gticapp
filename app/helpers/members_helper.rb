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
    #sentence = kanji
    #sentence = URI.encode(sentence)
    #key = 'dj0zaiZpPVR3TzJrbEJzRjRwTCZzPWNvbnN1bWVyc2VjcmV0Jng9OTg-'
    #base_url = 'http://jlp.yahooapis.jp/FuriganaService/V1/furigana'
    #req_url = "#{base_url}?sentence=#{sentence}&appid=#{key}"
    #response = Net::HTTP.get_response(URI.parse(req_url))
    #status = Hash.from_xml(response.body)
    #words = status["ResultSet"]["Result"]["WordList"]["Word"]
    #value = String.new
    #words.each do |word|
    #  if word["Furigana"].nil?
    #    value << word["Surface"]
    #  else
    #    value << word["Furigana"]
    #  end
    #end
    #value
  end

  def select_azsa(member)
    if member.azsa_flg
      link_to update_azsa_members_path(id: member.id), method: "post", remote: true, class:"btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to update_azsa_members_path(id: member.id, azsa_flg: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"fa fa-squqre")
      end
    end
  end

  def select_past_presenter(member)
    if member.past_presenter_flg
      link_to update_past_presenter_members_path(id: member.id), method: "post", remote: true, class:"btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to update_past_presenter_members_path(id: member.id, past_presenter_flg: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"fa fa-squqre")
      end
    end
  end

  def select_black_list_member(member)
    if member.black_list_flg
      link_to update_black_list_members_path(id: member.id), method: "post", remote: true, class:"btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to update_black_list_members_path(id: member.id, black_list_flg: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"fa fa-squqre")
      end
    end
  end

  def select_contributor(member)
    if member.contributor_flg
      link_to update_contributor_members_path(id: member.id), method: "post", remote: true, class:"btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to update_contributor_members_path(id: member.id, contributor_flg: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"fa fa-squqre")
      end
    end
  end

  def show_gender(gender)
    if gender == 1
      return "Male"
    elsif gender == 2
      return "Female"
    end
  end

  def show_age(age)
    if age == 1
      return "~20s"
    elsif age == 2
      return "30s"
    elsif age == 3
      return "40s"
    elsif age == 4
      return "50s"
    elsif age == 5
      return "60s~"
    end
  end

end
