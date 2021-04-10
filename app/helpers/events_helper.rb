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
      "欠席" #facebook参照
    when 1
      "未定" #facebook参照, dont use it sice 2021/4/6
    when 2
      "参加予定"
    when 3
      "出席"
    when 4
      "欠席" #手入力参照, 本当に欠席した人
    when 5
      "No-show"
    else
      "待機"
    end
  end

  def facebook_objects(fb_event_id)
    key = current_user.access_token
    graph = Koala::Facebook::API.new(key)
    begin
      return graph.get_connection(fb_event_id, '/')
    rescue => e
      return nil
    end
  end

  def select_status(member)
    relation = member.relationships.find_by_event_id(@event)
    status_code = relation.present? ? relation.status : nil
    case status_code
    when 2
      status_now = ["参加予定", 2]
      status_array = [["出席", 3], ["ドタ参", 6], ["欠席", 4], ["ドタキャン", 7], ["No-show", 5]]
    when 3
      status_now = ["出席", 3]
      status_array = [["参加予定", 2], ["ドタ参", 6], ["欠席", 4], ["ドタキャン", 7], ["No-show", 5]]
    when 0, 4
      status_now = ["欠席", 4]
      status_array = [["参加予定", 2], ["出席", 3], ["ドタ参", 6], ["ドタキャン", 7], ["No-show", 5]]
    when 5
      status_now = ["No-show", 5]
      status_array = [["参加予定", 2], ["出席", 3], ["ドタ参", 6], ["欠席", 4], ["ドタキャン", 7]]
    when 6
      status_now = ["ドタ参", 6]
      status_array = [["参加予定", 2], ["出席", 3], ["欠席", 4], ["ドタキャン", 7], ["No-show", 5]]
    when 7
      status_now = ["ドタキャン", 7]
      status_array = [["参加予定", 2], ["出席", 3], ["ドタ参", 6], ["欠席", 4], ["No-show", 5]]
    end

    case status_code
    when 1, nil
      link_to("追加", change_status_event_path(member_id: member.id, direction: 2), method: :post, class: "btn btn-xs btn-secondary", remote: true)
    else
      content_tag(:div, class: "btn-group") {
        concat content_tag(:button, class: "btn dropdown-toggle btn-info btn-xs", data: {toggle: "dropdown"}) {
          content_tag( :span, status_now[0], class: "caret")
        }
        concat content_tag(:div, class: "dropdown-menu", role: "menu") {
          status_array.each do |status|
            concat link_to(status[0], change_status_event_path(member_id: member.id, direction: status[1], referer: @referer), class: 'dropdown-item', method: 'post', remote: true)
          end
          concat link_to("Delete", destroy_relationship_event_path(member_id: member.id), class: 'dropdown-item', method: :post, remote: true)
        }
      }
    end
  end

  def select_role(member,event)
    record = member.relationships.find_by_event_id(event.id)
    gtic_flg = member.gtic_flg
    presentation_role = record.presentation_role

    # Role メニュー
    if presentation_role == 1
      title = ["Presenter","GTIC" ,"Panelist", "Moderator", "Guest", "過去登壇者", "参加者"]
      role = [nil, "gtic", "panelist", "moderator", "guest", "past_presenter", "participant"]
    elsif presentation_role == 2
      title = ["Panelist", "GTIC", "Presenter", "Moderator", "Guest", "過去登壇者", "参加者"]
      role = [nil, "gtic", "presenter", "moderator", "guest", "past_presenter", "participant"]
    elsif presentation_role == 3
      title = ["Moderator", "GTIC", "Presenter", "Panelist", "Guest", "過去登壇者", "参加者"]
      role = [nil, "gtic", "presenter", "panelist","guest", "past_presenter", "participant"]
    elsif presentation_role == 4
      title = ["Guest", "GTIC", "Presenter", "Panelist", "Moderator", "過去登壇者", "参加者"]
      role = [nil, "gtic", "presenter", "panelist", "moderator", "past_presenter", "participant"]
    elsif presentation_role == 5
      title = ["過去登壇者", "GTIC", "Presenter", "Panelist", "Moderator", "Guest", "参加者"]
      role = [nil, "gtic", "presenter", "panelist", "moderator", "guest", "participant"]
    elsif gtic_flg
      title = ["GTIC", "Presenter", "Panelist", "Moderator", "Guest", "過去登壇者", "参加者"]
      role = [nil, "presenter", "panelist", "moderator", "guest", "past_presenter", "participant"]
    else
      title = ["参加者", "GTIC", "Presenter", "Panelist", "Moderator", "Guest", "過去登壇者"]
      role = [nil, "gtic", "presenter", "panelist", "moderator", "guest", "past_presenter"]
    end
    content_tag(:div, class: "btn-group") {
      concat content_tag(:button, "#{title[0]} #{content_tag(:span, '', class: 'caret')}".html_safe, class: "dropdown-toggle btn btn-xs btn-info", data: {toggle: "dropdown"})
      concat content_tag(:div, class: "dropdown-menu", role: "menu", 'aria-labelledby': "dLabel") {
        concat link_to(title[1], change_role_event_path(member_id: member.id, role: role[1], referer: @referer), class: 'dropdown-item', method: 'post', remote: true)
        concat link_to(title[2], change_role_event_path(member_id: member.id, role: role[2], referer: @referer), class: 'dropdown-item', method: 'post', remote: true)
        concat link_to(title[3], change_role_event_path(member_id: member.id, role: role[3], referer: @referer), class: 'dropdown-item', method: 'post', remote: true)
        concat link_to(title[4], change_role_event_path(member_id: member.id, role: role[4], referer: @referer), class: 'dropdown-item', method: 'post', remote: true)
        concat link_to(title[5], change_role_event_path(member_id: member.id, role: role[5], referer: @referer), class: 'dropdown-item', method: 'post', remote: true)
        concat link_to(title[6], change_role_event_path(member_id: member.id, role: role[6], referer: @referer), class: 'dropdown-item', method: 'post', remote: true)
      }
    }
  end

  def show_fee(member, event)
    record = member.relationships.find_by_event_id(event.id)
    presentation_role = record.presentation_role
    gtic_flg = member.gtic_flg
    past_presenter_flg = member.past_presenter_flg

    # Birthday
    if member.birthday
      if member.birthday.strftime("%m") == event.start_time.strftime("%m")
        birthday_flg = true
      else
        birthday_flg = false
      end
    else
      birthday_flg = false
    end
    fee = event.fee || 0

    if birthday_flg
      fee -= 1000
    end

    student_flg = member.category_id == 10 ? true : false
    if student_flg
      fee -= 2000
    end

    if past_presenter_flg
      fee -= 2000
    end

    if member.contributor_flg
      fee -= 1000
    end

    if ((0 < presentation_role) && (presentation_role < 5) || gtic_flg)
      fee = 0
    end
    fee
  end

  def select_birthday(member, event)
    if member.birthday
      if member.birthday.strftime("%m") == event.start_time.strftime("%m")
        link_to update_birthday_event_path(member_id: member.id, referer: @referer), method: "post", remote: true, class:"btn btn-xs" do
          content_tag(:span, "", class:"fa fa-check")
        end
      else
        content_tag :button, disabled: "disabled", class: "btn btn-default btn-xs" do
          content_tag(:span, "", class:"fa fa-square")
        end
      end
    else
      link_to update_birthday_event_path(member_id: member.id, referer: @referer, birthday: true), method: "post", remote: true, class:"btn btn-xs" do
        content_tag(:span, "", class:"fa fa-square")
      end
    end
  end

  def select_black_list(member, event)
    if member.black_list_flg
      link_to switch_black_list_flg_event_path(member_id: member.id, referer: @referer), method: "post", remote: true, class:"btn btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to switch_black_list_flg_event_path(member_id: member.id, referer: @referer, black_list_flg: true), method: "post", remote: true, class:"btn btn-xs" do
        content_tag(:span, "", class:"fa fa-square")
      end
    end
  end

  def show_note(member, event) # Not use since 2019-04-13
    relationship = member.relationships.find_by_event_id(event.id)
    if relationship.note
      link_to edit_relationship_path(relationship.id), class: "btn btn-secondary btn-xs", remote: true do
        content_tag :span, "", class: "fa fa-check note", data: {content: relationship.note }
      end
    else
      link_to edit_relationship_path(relationship.id), class: "btn btn-default btn-xs", remote: true do
        content_tag :span, "", class: "fa fa-square"
      end
    end
  end

end
