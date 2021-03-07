module StaffsHelper

  def select_active(staff)
    if staff.active_flg
      link_to update_active_staffs_path(id: staff.id), method: "post", remote: true, class:"btn btn-primary btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-check")
      end
    else
      link_to update_active_staffs_path(id: staff.id, active_flg: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-unchecked")
      end
    end
  end

  def select_admin(staff)
    if staff.admin
      link_to update_admin_staffs_path(id: staff.id), method: "post", remote: true, class:"btn btn-primary btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-check")
      end
    else
      link_to update_admin_staffs_path(id: staff.id, admin: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-unchecked")
      end
    end
  end

end