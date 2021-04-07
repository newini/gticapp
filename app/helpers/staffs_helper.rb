module StaffsHelper

  def get_check_icon(flag)
    if flag
      content_tag(:icon, "", class:"fa fa-check")
    else
      content_tag(:icon, "", class:"fa fa-square")
    end
  end

  def get_name_from_member_id(member_id)
    member = Member.find_by_id(member_id)
    return member.last_name + " " + member.first_name
  end

  def get_facebook_user_id_link_from_member_id(member_id)
    member = Member.find_by_id(member_id)
    link_to "#{member.uid}", "https://facebook.com/#{member.uid}", target: :blank
  end

end
