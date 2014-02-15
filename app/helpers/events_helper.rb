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

end
