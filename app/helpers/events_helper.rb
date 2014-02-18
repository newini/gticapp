module EventsHelper
  def relationship(participant)
    Relationship.where(participated_id: @event.id).find_by_participant_id(participant.id)
  end
  def check_event_flg(participant)
    presenter_flg = Relationship.where(participated_id: @event.id).find_by_participant_id(participant.id).presenter_flg
    if presenter_flg == true
      "o"
    else
      "x"
    end
  end
  def show_status(member)
    relationship = @event.relationships.find_by_member_id(member.id)
    case relationship.status
    when 0
      "招待待ち"
    when 1
      "招待済み"
    when 2
      "参加予定"
    when 3
      "出席"
    when 4
      "キャンセル"
    when 5
      "No-show"
    else
      "招待待ち"
    end
  end

  def facebook(fb_event_id, status)
#    base_url = 'https://graph.facebook.com/oauth/access_token'
#    app_id = '532180836901393'
#    app_secret = '5c9a4eccb9eca78840346577d032f9b4'
#    user_access_token = 'CAAHkBAG9YhEBAN2h9HorstBfIvW2mqdAjAggqeco6c6WY4PHHqOwmABMZAXgfgIZArYetmPZAEbKR8TxigDLsnXvopxvf8REnZBXJEOVjQ8maIBMZBSDjDVfH87y1cmYKxUXeKT6lwZBZAS3TIPODjZCUHadZByJtGJsaaE5y1ZBOC06Ga6s1L82yugbn7SLoTvu6znstDtZA5ijgZDZD'
#    user_access_token= 'CAAHkBAG9YhEBAN2h9HorstBfIvW2mqdAjAggqeco6c6WY4PHHqOwmABMZAXgfgIZArYetmPZAEbKR8TxigDLsnXvopxvf8REnZBXJEOVjQ8maIBMZBSDjDVfH87y1cmYKxUXeKT6lwZBZAS3TIPODjZCUHadZByJtGJsaaE5y1ZBOC06Ga6s1L82yugbn7SLoTvu6znstDtZA5ijgZDZD'
#    app_access_token = '532180836901393|XRWoGGex7zFt7Z1e4IxplD8U9iA'
#    req_url = "#{base_url}?grant_type=fb_exchange_token&client_id=#{app_id}&client_secret=#{app_secret}&fb_exchange_token=#{user_access_token}"
#    response = Net::HTTP.get_response(URI.parse(req_url))
#    key = response.body.split("&").first.split("=").last

#    key = current_user.token
    key = 'CAAHkBAG9YhEBAMax5WL2M3U7rxpOpn6ukXx8ZAVcUWxFBXuOZB1ec2a3KdZALVyAoikmZC216bbMze8hae1cc9pcz7DHlH1zjZC7NQfBttEllgYER4rt2s4cJbX58zhIL1h2XheHyuWctfTJ1ucKnW6TJ0a7DzZB1N6s4afEZC8lmQZBi9szb4uOVZARGZA2kkBgUZD'
    graph = Koala::Facebook::API.new(key)
    return graph.get_connections(fb_event_id, status, locale: "jp_JP")
  end
  def convert_status(rsvp_status)
    case rsvp_status
    when "attending"
      2
    end
  end
    


end
