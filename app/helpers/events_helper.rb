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
      "欠席"
      #facebook参照
    when 1
      "未定"
    when 2
      "参加予定"
    when 3
      "出席"
    when 4
      "欠席"
      #手入力参照
    when 5
      "No-show"
    else
      "待機"
    end
  end

  def facebook(fb_event_id, status)
    key = current_user.access_token
    graph = Koala::Facebook::API.new(key)
    graph.get_connections(fb_event_id, status, locale: "jp_JP")
  end

  def facebook_objects(fb_event_id)
    key = current_user.access_token
    graph = Koala::Facebook::API.new(key)
    graph.get_objects(fb_event_id)
  end


  def convert_status(rsvp_status)
    case rsvp_status
    when "declined"
      0 
    when "maybe"
      1
    when "attending"
      2
    end
  end

  def select_status(member)
    relation = member.relationships.find_by_event_id(@event)
    status = relation.present? ? relation.status : nil
    case status
    when 1, nil
      link_to("追加", change_status_event_path(:member_id => member.id, :direction => 2), :method => :post, :class => "btn btn-xs btn-primary", remote: true)
    when 2
      content_tag(:div, class: "btn-group") {
        concat link_to( "出席", change_status_event_path(:member_id => member.id, :direction => 3, referer: @referer), :method => :post, :class => "btn btn-xs btn-primary ", remote: true)
        concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", data: {:toggle => "dropdown"}){ 
          content_tag( :span, "", class: "caret")
        } 
        concat content_tag(:ul, class: "dropdown-menu", role: "menu"){ 
          content_tag(:li){
            concat link_to("欠席", change_status_event_path(:member_id => member.id, :direction => 4, referer: @referer), :method => :post, remote: true) 
            concat link_to("No-show", change_status_event_path(:member_id => member.id, :direction => 5, referer: @referer), :method => :post, remote: true)
          }
        }
      }
    when 3
      content_tag(:div, class: "btn-group"){ 
        concat link_to "欠席", change_status_event_path(:member_id => member.id, :direction => 4, referer: @referer), :method => :post, :class => "btn btn-xs btn-primary ", remote: true
        concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", :"data-toggle" => "dropdown"){ 
          content_tag :span, "",  class: "caret"
        }
        concat content_tag( :ul, class: "dropdown-menu", role: "menu"){ 
          content_tag(:li){
            concat link_to("No-show", change_status_event_path(:member_id => member.id, :direction => 5, referer: @referer), :method => :post, remote: true)
            concat link_to("参加予定", change_status_event_path(:member_id => member.id, :direction => 2, referer: @referer), :method => :post, remote: true)
          }
        }
      }
    when 0, 4
      content_tag(:div, class: "btn-group"){ 
        concat link_to("出席", change_status_event_path(:member_id => member.id, :direction => 3, referer: @referer), :method => :post, :class => "btn btn-xs btn-primary ", remote: true)
        concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", :"data-toggle" => "dropdown"){
          content_tag(:span,"", class: "caret")
        }
        concat content_tag(:ul, class: "dropdown-menu", role: "menu"){
          content_tag(:li){ 
            concat link_to("No-show", change_status_event_path(:member_id => member.id, :direction => 5, referer: @referer), :method => :post, remote: true)
            concat link_to("参加予定", change_status_event_path(:member_id => member.id, :direction => 2, referer: @referer), :method => :post, remote: true)
          }
        }
      }
    when 5
      content_tag(:div, class: "btn-group"){ 
        concat link_to(switch_black_list_flg_event_path(member_id: member.id, referer: @referer), method: :post, class: "btn btn-xs btn-primary ", remote: true){
          member.black_list_flg ? "B-L解除" : "B-L" 
        }
        concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", :"data-toggle" => "dropdown"){
          content_tag(:span,"", class: "caret")
        }
        concat content_tag(:ul, class: "dropdown-menu", role: "menu"){
          content_tag(:li){
            concat link_to("出席", change_status_event_path(:member_id => member.id, :direction => 3, referer: @referer), :method => :post, remote: true)
            concat link_to("欠席", change_status_event_path(:member_id => member.id, :direction => 4, referer: @referer), :method => :post, remote: true)
            concat link_to("参加予定", change_status_event_path(:member_id => member.id, :direction => 2, referer: @referer), :method => :post, remote: true)
          }
        }
      }
    end
  end

  def select_role(member,event)
    record = member.relationships.find_by_event_id(event.id)
    gtic_flg = member.gtic_flg
    presentation_role = record.presentation_role
    # Role メニュー 
    if presentation_role == 2
      title = ["Panelist", "GTIC", "プレゼンター", "Moderator", "ゲスト", "参加者"]
      role = [nil, "gtic", "presenter", "moderator", "guest", "participant"]
    elsif presentation_role == 3
      title = ["Moderator", "GTIC", "プレゼンター", "Panelist", "ゲスト", "参加者"]
      role = [nil, "gtic", "presenter", "panelist","guest", "participant"]
    elsif presentation_role == 1
      title = ["プレゼンター","GTIC" ,"Panelist", "Moderator", "ゲスト", "参加者"]
      role = [nil, "gtic", "panelist", "moderator", "guest", "participant"]
    elsif presentation_role == 4
      title = ["ゲスト", "GTIC", "プレゼンター", "Panelist", "Moderator", "参加者"]
      role = [nil, "gtic", "presenter", "panelist", "moderator", "participant"]
    elsif gtic_flg
      title = ["GTIC", "プレゼンター", "Panelist", "Moderator", "ゲスト", "参加者"]
      role = [nil, "presenter", "panelist", "moderator", "guest","participant"]
    else
      title = ["参加者", "GTIC", "プレゼンター", "Panelist", "Moderator", "ゲスト"]
      role = [nil, "gtic", "presenter", "panelist", "moderator", "guest"]
    end
      content_tag(:div, class: "btn-group") {
        concat content_tag(:button,"#{title[0]} #{content_tag(:span, '', class: 'caret')}".html_safe, :class => "dropdown-toggle btn btn-xs btn-default", data: {:toggle => "dropdown"})
        concat content_tag(:ul, class: "dropdown-menu", role: "menu", :"aria-labelledby" => "dLabel"){ 
          content_tag(:li){
            concat link_to(title[1], change_role_event_path(:member_id => member.id, :role => role[1], referer: @referer), :method => :post, remote: true) 
            concat link_to(title[2], change_role_event_path(:member_id => member.id, :role => role[2], referer: @referer), :method => :post, remote: true) 
            concat link_to(title[3], change_role_event_path(:member_id => member.id, :role => role[3], referer: @referer), :method => :post, remote: true) 
            concat link_to(title[4], change_role_event_path(:member_id => member.id, :role => role[4], referer: @referer), :method => :post, remote: true) 
            concat link_to(title[5], change_role_event_path(:member_id => member.id, :role => role[5], referer: @referer), :method => :post, remote: true) 
          }
        }
      }
  end
    
  def show_fee(member,event)
    record = member.relationships.find_by_event_id(event.id)
    presentation_role = record.presentation_role
    gtic_flg = member.gtic_flg
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

    student_flg = member.category_id == 10 ? true : false
    if student_flg
      fee -= 2000 
    end

    if birthday_flg
      fee -= 1000
    end

    if ((presentation_role != 0) || gtic_flg)
      fee = 0
    end
    fee
  end

  def select_birthday(member, event)
    if member.birthday
      if member.birthday.strftime("%m") == event.start_time.strftime("%m")
        link_to update_birthday_event_path(member_id: member.id, referer: @referer), method: "post", remote: true, class:"btn btn-primary btn-xs" do
          content_tag(:span, "", class:"glyphicon glyphicon-check") 
        end
      else
        content_tag :button, disabled: "disabled", class: "btn btn-default btn-xs" do
          content_tag(:span, "", class:"glyphicon glyphicon-unchecked")
        end
      end
    else
      link_to update_birthday_event_path(member_id: member.id, referer: @referer, birthday: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-unchecked")
      end
    end
  end

  def show_birthday(member, event)
    if member.birthday
      if member.birthday.strftime("%m") == event.start_time.strftime("%m")
        return "B" 
      else
        return ""
      end
    else
      return ""
    end
  end

  def show_note(member, event)
    relationship = member.relationships.find_by_event_id(event.id)
    if relationship.note
      link_to edit_relationship_path(relationship.id), class: "btn btn-primary btn-xs", remote: true do
        content_tag :span, "", class: "glyphicon glyphicon-check note", data: {content: relationship.note }
      end
    else
      link_to edit_relationship_path(relationship.id), class: "btn btn-default btn-xs", remote: true do
        content_tag :span, "", class: "glyphicon glyphicon-unchecked"
      end
    end
  end

end
