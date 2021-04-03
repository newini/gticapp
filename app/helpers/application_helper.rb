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
    if current_user.present?
      staff = Staff.find_by_uid(current_user.uid)
      if staff.present?
        return true
      end
    end
    return false
  end

  def admin?
    if current_user.present?
      staff = Staff.find_by_uid(current_user.uid)
      return staff.admin if staff
    end
    return false

    current_staff
    @current_staff.admin if current_staff
  end

end
