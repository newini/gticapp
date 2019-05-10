module UsersHelper

  def select_active(user)
    if user.active_flg
      link_to update_active_users_path(id: user.id), method: "post", remote: true, class:"btn btn-primary btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-check")
      end
    else
      link_to update_active_users_path(id: user.id, active_flg: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-unchecked")
      end
    end
  end

  def select_admin(user)
    if user.admin
      link_to update_admin_users_path(id: user.id), method: "post", remote: true, class:"btn btn-primary btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-check")
      end
    else
      link_to update_admin_users_path(id: user.id, admin: true), method: "post", remote: true, class:"btn btn-default btn-xs" do
        content_tag(:span, "", class:"glyphicon glyphicon-unchecked")
      end
    end
  end

end
