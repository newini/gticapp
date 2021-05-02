module ApplicationHelper

  def sortable(column, title)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == 'asc') ? "desc" : "asc"
    link_to title, sort: column, direction: direction
  end

  def show_date(date)
    date.strftime("%Y/%m/%d (%a.)") if date.present?
  end

  def show_time(time)
    time.strftime("%H:%M") if time.present?
  end

  def show_datetime(datetime)
    datetime.strftime("%Y/%m/%d %H:%M") if datetime.present?
  end

  def show_currency(number)
    number_to_currency(number, format: "%u%n", unit: "￥", precision: 0, separator: ",") if number.present?
  end

  def show_role(member, event)
    record = member.relationships.find_by_event_id(event.id)
    presentation_role = record.presentation_role
    gtic_flg = member.gtic_flg
    student_flg = member.category_id == 10 ? true : false
    if gtic_flg
      return "GTIC"
    else
      if presentation_role == 1
        return "プレゼンター"
      elsif presentation_role == 2
        return "Panelist"
      elsif presentation_role == 3
        return "Moderator"
      elsif presentation_role == 4
        return "ゲスト"
      elsif student_flg
        return "学生"
      else
        return "参加者"
      end
    end
  end

  def staff_signed_in?
    return true if ENV['RAILS_ENV'] == 'development'
    if current_user.present?
      member = Member.where(provider: current_user.provider, uid: current_user.uid).first
      staff = Staff.find_by_member_id(member.id) if member
      return staff.is_active if staff
    end
    return false
  end

  def admin?
    return true if ENV['RAILS_ENV'] == 'development'
    if current_user.present?
      member = Member.where(provider: current_user.provider, uid: current_user.uid).first
      staff = Staff.find_by_member_id(member.id) if member
      return staff.is_admin if staff
    end
    return false
  end

end
