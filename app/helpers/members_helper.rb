module MembersHelper
  def check_member_flg(event)
    presenter_flg = Relationship.where(participated_id: event.id).find_by_participant_id(@member).presenter_flg
    if presenter_flg == true
      "○"
    else
      "x"
    end
  end

end
