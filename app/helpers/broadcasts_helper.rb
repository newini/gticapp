module BroadcastsHelper

  def select_include_all_members(broadcast)
    if broadcast.include_all_flg
      link_to update_include_all_flg_broadcast_path(broadcast), method: "post", remote: true, class: "btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to update_include_all_flg_broadcast_path(broadcast), method: "post", remote: true, class: "btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-square")
      end
    end
  end

  def select_month(broadcast)
    content_tag(:div, class: "btn-group") {
      concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", data: {:toggle => "dropdown"}) {
        content_tag(:span, "クリックして誕生月選択", class: "caret")
      }
      concat content_tag(:div, class: "dropdown-menu", role: "menu", style: 'max-height: 300px; overflow: scroll;') {
        concat link_to("全て外す", update_birth_month_broadcast_path(broadcast, :birth_month => "00"), method: 'post',  class: 'dropdown-item', remote: true)
        (1..12).each do |month|
          concat link_to(t('date.abbr_month_names')[month], update_birth_month_broadcast_path(broadcast, birth_month: month.to_s.rjust(2, "0")), method: 'post', class: 'dropdown-item', remote: true)
        end
      }
    }
  end

  def select_event(broadcast, events)
    content_tag(:div, class: "btn-group") {
      concat content_tag(:button, class: "btn dropdown-toggle btn-primary btn-xs", data: {:toggle => "dropdown"}) {
        content_tag(:span, "クリックしてイベント選択", class: "caret")
      }
      concat content_tag(:div, class: "dropdown-menu", role: "menu", style: "max-height: 300px; overflow: scroll;") {
        concat link_to("全て外す", update_event_id_broadcast_path(broadcast, :event_id => 0), method: 'post', class: 'dropdown-item', remote: true)
        events.each do |event|
          concat link_to("第#{event.cumulative_number}回", update_event_id_broadcast_path(broadcast, :event_id => event.id), method: 'post', class: 'dropdown-item', remote: true)
        end
      }
    }
  end

  def select_include_gtic_members(broadcast)
    if broadcast.include_gtic_flg
      link_to update_include_gtic_flg_broadcast_path(broadcast), method: "post", remote: true, class: "btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to update_include_gtic_flg_broadcast_path(broadcast), method: "post", remote: true, class: "btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-square")
      end
    end
  end

  def select_to_invite(broadcast, member)
    link_to("追加", update_broadcast_member_broadcast_path(broadcast, member_id: member.id), method: 'post', class: "btn btn-primary btn-xs", remote: true)
  end

  def select_to_delete(broadcast, member)
    link_to("削除", delete_broadcast_member_broadcast_path(broadcast, member_id: member.id), method: 'post', class: "btn btn-primary btn-xs", remote: true)
  end

end
