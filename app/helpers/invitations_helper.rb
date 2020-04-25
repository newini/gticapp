module InvitationsHelper

  def select_month(invitation)
    content_tag(:div, class: "btn-group") {
      concat content_tag(:button, class: "btn dropdown-toggle btn-default btn-xs", data: {:toggle => "dropdown"}) {
        content_tag(:span, "", class: "caret")
        content_tag(:span, "", class: "glyphicon glyphicon-birthday-cake")
        content_tag(:p, "誕生月者に送信（クリックして誕生月選択）")
      }
      concat content_tag(:ul, "asd", class: "dropdown-menu", role: "menu") {
        content_tag(:li) {
          concat link_to("Jan.", send_birth_month_invitation_path(invitation, :month => "01"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '1月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Feb.", send_birth_month_invitation_path(invitation, :month => "02"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '2月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Mar.", send_birth_month_invitation_path(invitation, :month => "03"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '3月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Apr.", send_birth_month_invitation_path(invitation, :month => "04"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '4月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("May", send_birth_month_invitation_path(invitation, :month => "05"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '5月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Jan.", send_birth_month_invitation_path(invitation, :month => "06"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '6月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Jul.", send_birth_month_invitation_path(invitation, :month => "07"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '7月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Aug.", send_birth_month_invitation_path(invitation, :month => "08"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '8月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Sep.", send_birth_month_invitation_path(invitation, :month => "09"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '9月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Oct.", send_birth_month_invitation_path(invitation, :month => "10"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '10月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Nov.", send_birth_month_invitation_path(invitation, :month => "11"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '11月誕生月者に送信します。よろしいでしょうか？'})
          concat link_to("Dec.", send_birth_month_invitation_path(invitation, :month => "12"), :method => :post, :class => "btn btn-xs", remote: true,
                         data: {confirm: '12月誕生月者に送信します。よろしいでしょうか？'})
        }
      }
    }
  end

  def select_event(invitation, events)
    content_tag(:div, class: "btn-group") {
      concat content_tag(:button, class: "btn dropdown-toggle btn-default btn-xs", data: {:toggle => "dropdown"}) {
        content_tag(:span, "", class: "glyphicon glyphicon-download")
        content_tag(:span, "", class: "caret")
        content_tag(:p, "イベント会合出席者に送信（クリックしてイベント選択）")
      }
      concat content_tag(:ul, "asd", class: "dropdown-menu", role: "menu", style: "max-height: 400px; overflow: scroll;") {
        content_tag(:li) {
          events.each do |event|
            concat link_to("#{event.name}", send_event_invitation_path(invitation, :event_id => event.id), :method => :post, :class => "btn btn-xs", remote: true,
                           data: {confirm: "#{event.name}に送信します。よろしいでしょうか？"})
          end
        }
      }
    }
  end

  def select_include_gtic_members(invitation)
    if invitation.include_gtic_flg
      link_to update_include_gtic_flg_invitation_path(invitation), method: "post", remote: true, class: "btn btn-primary btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-check")
      end
    else
      link_to update_include_gtic_flg_invitation_path(invitation), method: "post", remote: true, class: "btn btn-default btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-unchecked")
      end
    end
  end


end
