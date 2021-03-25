module InvitationsHelper

  def select_include_all_members(invitation)
    if invitation.include_all_flg
      link_to update_include_all_flg_invitation_path(invitation), method: "post", remote: true, class: "btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to update_include_all_flg_invitation_path(invitation), method: "post", remote: true, class: "btn btn-default btn-xs" do
        content_tag(:span, "", class:"fa fa-squqre")
      end
    end
  end

  def select_month(invitation)
    content_tag(:div, class: "btn-group") {
      concat content_tag(:button, class: "btn dropdown-toggle btn-default btn-xs", data: {:toggle => "dropdown"}) {
        content_tag(:span, "", class: "caret")
        content_tag(:span, "", class: "fa fa-birthday-cake")
        content_tag(:p, "クリックして誕生月選択")
      }
      concat content_tag(:ul, "asd", class: "dropdown-menu", role: "menu") {
        content_tag(:li) {
          concat link_to("全ての誕生月者を外す", update_birth_month_invitation_path(invitation, :birth_month => "00"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Jan.", update_birth_month_invitation_path(invitation, :birth_month => "01"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Feb.", update_birth_month_invitation_path(invitation, :birth_month => "02"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Mar.", update_birth_month_invitation_path(invitation, :birth_month => "03"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Apr.", update_birth_month_invitation_path(invitation, :birth_month => "04"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("May", update_birth_month_invitation_path(invitation, :birth_month => "05"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Jan.", update_birth_month_invitation_path(invitation, :birth_month => "06"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Jul.", update_birth_month_invitation_path(invitation, :birth_month => "07"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Aug.", update_birth_month_invitation_path(invitation, :birth_month => "08"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Sep.", update_birth_month_invitation_path(invitation, :birth_month => "09"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Oct.", update_birth_month_invitation_path(invitation, :birth_month => "10"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Nov.", update_birth_month_invitation_path(invitation, :birth_month => "11"), :method => :post, :class => "btn btn-xs", remote: true)
          concat link_to("Dec.", update_birth_month_invitation_path(invitation, :birth_month => "12"), :method => :post, :class => "btn btn-xs", remote: true)
        }
      }
    }
  end

  def select_event(invitation, events)
    content_tag(:div, class: "btn-group") {
      concat content_tag(:button, class: "btn dropdown-toggle btn-default btn-xs", data: {:toggle => "dropdown"}) {
        content_tag(:span, "", class: "fa fa-download")
        content_tag(:span, "", class: "caret")
        content_tag(:p, "クリックしてイベント選択")
      }
      concat content_tag(:ul, "asd", class: "dropdown-menu", role: "menu", style: "max-height: 400px; overflow: scroll;") {
        content_tag(:li) {
          concat link_to("全てのイベント会合出席者を外す", update_event_id_invitation_path(invitation, :event_id => 0), :method => :post, :class => "btn btn-xs", remote: true)
          events.each do |event|
            concat link_to("第#{event.cumulative_number}回", update_event_id_invitation_path(invitation, :event_id => event.id), :method => :post, :class => "btn btn-xs", remote: true)
          end
        }
      }
    }
  end

  def select_include_gtic_members(invitation)
    if invitation.include_gtic_flg
      link_to update_include_gtic_flg_invitation_path(invitation), method: "post", remote: true, class: "btn btn-primary btn-xs" do
        content_tag(:span, "", class:"fa fa-check")
      end
    else
      link_to update_include_gtic_flg_invitation_path(invitation), method: "post", remote: true, class: "btn btn-default btn-xs" do
        content_tag(:span, "", class:"fa fa-squqre")
      end
    end
  end

  def select_to_invite(invitation, member)
    link_to("追加", update_member_invitation_invitation_path(invitation, :member_id => member.id), :method => :post, :class => "btn btn-primary btn-xs", id: member.id, remote: true)
  end

  def select_to_delete(invitation, member)
    link_to("削除", delete_member_invitation_invitation_path(invitation, :member_id => member.id), :method => :post, :class => "btn btn-primary btn-xs", id: member.id, remote: true)
  end

end
