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
  def check_invite_flg(member)
    invited_flg = Connection.where(invited_event_id: @event.id).find_by_invited_member_id(member.id).present?
    if invited_flg == true
      "o"
    else
      "x"
    end
  end

end
