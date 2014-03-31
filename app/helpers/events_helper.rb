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
    when 1
      "未定"
    when 2
      "参加予定"
    when 3
      "出席"
    when 4
      "欠席"
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
    when "attending"
      2
    when "declined"
      4
    when "maybe"
      1
    end
  end

  def select_status(member)
    relation = member.relationships.find_by_event_id(@event)
    status = relation.present? ? relation.status : nil
    case status
    when 1, 0, nil
      link_to("追加", change_status_event_path(:member_id => member.id, :direction => 2), :method => :post, :class => "btn btn-xs btn-primary")
    when 2
      content_tag(:div, class: "btn-group") {
        concat link_to( "出席", change_status_event_path(:member_id => member.id, :direction => 3), :method => :post, :class => "btn btn-xs btn-primary ")
        concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", data: {:toggle => "dropdown"}){ 
          content_tag( :span, "", class: "caret")
        } 
        concat content_tag(:ul, class: "dropdown-menu", role: "menu"){ 
          content_tag(:li){
            concat link_to("キャンセル", change_status_event_path(:member_id => member.id, :direction => 4), :method => :post) 
            concat link_to("No-show", change_status_event_path(:member_id => member.id, :direction => 5), :method => :post)
          }
        }
      }
    when 3
      content_tag(:div, class: "btn-group"){ 
        concat link_to "キャンセル", change_status_event_path(:member_id => member.id, :direction => 4), :method => :post, :class => "btn btn-xs btn-primary "
        concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", :"data-toggle" => "dropdown"){ 
          content_tag :span, "",  class: "caret"
        }
        concat content_tag( :ul, class: "dropdown-menu", role: "menu"){ 
          content_tag(:li){
            concat link_to("No-show", change_status_event_path(:member_id => member.id, :direction => 5), :method => :post)
            concat link_to("参加予定", change_status_event_path(:member_id => member.id, :direction => 2), :method => :post)
          }
        }
      }
    when 4
      content_tag(:div, class: "btn-group"){ 
        concat link_to("出席", change_status_event_path(:member_id => member.id, :direction => 3), :method => :post, :class => "btn btn-xs btn-primary ")
        concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", :"data-toggle" => "dropdown"){
          content_tag(:span,"", class: "caret")
        }
        concat content_tag(:ul, class: "dropdown-menu", role: "menu"){
          content_tag(:li){ 
            concat link_to("No-show", change_status_event_path(:member_id => member.id, :direction => 5), :method => :post)
            concat link_to("参加予定", change_status_event_path(:member_id => member.id, :direction => 2), :method => :post)
          }
        }
      }
    when 5
      content_tag(:div, class: "btn-group"){ 
        concat link_to(switch_black_list_flg_event_path(:member_id => member.id), :method => :post, :class => "btn btn-xs btn-primary "){
          member.black_list_flg == (false || nil) ? "ブラックリスト入り" : "ブラックリスト解除" 
        }
        concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", :"data-toggle" => "dropdown"){
          content_tag(:span,"", class: "caret")
        }
        concat content_tag(:ul, class: "dropdown-menu", role: "menu"){
          content_tag(:li){
            concat link_to("出席", change_status_event_path(:member_id => member.id, :direction => 3), :method => :post)
            concat link_to("キャンセル", change_status_event_path(:member_id => member.id, :direction => 4), :method => :post)
            concat link_to("参加予定", change_status_event_path(:member_id => member.id, :direction => 2), :method => :post)
          }
        }
      }
    end
  end

  def select_role(member,event)
    @record = member.relationships.find_by_event_id(event.id)
    @presenter_flg = @record.presenter_flg
    @guest_flg = @record.guest_flg
    @gtic_flg = member.gtic_flg
    if @gtic_flg
      content_tag :span, "GTIC"
    elsif @presenter_flg
      content_tag(:div, class: "dropdown") {
        concat link_to("プレゼンター", "#", :class => "dropdown-toggle", data: {:toggle => "dropdown"})
        concat content_tag(:ul, class: "dropdown-menu", role: "menu", :"aria-labelledby" => "dLabel"){ 
          content_tag(:li){
            concat link_to("ゲスト", switch_presenter_flg_event_path(:member_id => member.id, :switch => "on"), :method => :post) 
            concat link_to("参加者", switch_presenter_flg_event_path(:member_id => member.id, :switch => "off"), :method => :post) 
          }
        }
      }
    elsif @guest_flg
      content_tag(:div, class: "dropdown") {
        concat link_to("ゲスト", "#", :class => "dropdown-toggle", data: {:toggle => "dropdown"})
        concat content_tag(:ul, class: "dropdown-menu", role: "menu", :"aria-labelledby" => "dLabel"){ 
          content_tag(:li){
            concat link_to("プレゼンター", switch_presenter_flg_event_path(:member_id => member.id, :switch => "on"), :method => :post) 
            concat link_to("参加者", switch_guest_flg_event_path(:member_id => member.id, :switch => "off"), :method => :post) 
          }
        }
      }
    else
      content_tag(:div, class: "dropdown") {
        concat link_to("参加者", "#", :class => "dropdown-toggle", data: {:toggle => "dropdown"})
        concat content_tag(:ul, class: "dropdown-menu", role: "menu", :"aria-labelledby" => "dLabel"){ 
          content_tag(:li){
            concat link_to("プレゼンター", switch_presenter_flg_event_path(:member_id => member.id, :switch => "on"), :method => :post) 
            concat link_to("ゲスト", switch_guest_flg_event_path(:member_id => member.id, :switch => "on"), :method => :post) 
          }
        }
      }
    end
  end
    
  def show_fee(member,event)
    @record = member.relationships.find_by_event_id(event.id)
    @prenseter_flg = @record.presenter_flg
    @guest_flg = @record.guest_flg
    @gtic_flg = member.gtic_flg
    @student_flg = member.category_id == 10 ? true : false
    if ((@presenter_flg || @guest_flg) || @gtic_flg)
      return 0
    elsif @student_flg
      return event.fee - 1000 if event.fee.present?
    else
      return event.fee
    end
  end

  def waiting_members
    ids = Member.joins(:relationships).where(:relationships =>{event_id: @event.id}).where(:relationships => {status: 2..6}).uniq
    Member.where.not(id: ids)
  end

end
